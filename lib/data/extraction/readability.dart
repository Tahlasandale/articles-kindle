import 'dart:math' as math;

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Extraction du contenu lisible d'une page.
///
/// Pas de port de Readability à maintenir : un score de densité maison, testé
/// sur le corpus réel (voir test/data/extraction_test.dart). L'objectif n'est pas
/// de deviner « l'article » au sens éditorial, mais de garder le gros bloc de
/// texte et de jeter navigation, encadrés et bruit.
class Readability {
  Readability._();

  /// En dessous de cette quantité de texte, on ne fabrique pas de chapitre : le
  /// résultat est une page vide, on préfère le dire.
  static const int minimumTextLength = 400;

  static const Set<String> _strippedTags = {
    'script',
    'style',
    'noscript',
    'iframe',
    'object',
    'embed',
    'form',
    'button',
    'input',
    'select',
    'textarea',
    'svg',
    'canvas',
    'template',
    'link',
    'meta',
    'nav',
    'aside',
    'footer',
  };

  /// Sélecteurs de ce qui ne contient jamais l'article : la navigation et les
  /// encadrés sont structurels, le reste est une liste de mots-clés. La
  /// comparaison se fait sur le nom entier pour ne pas tuer un « masthead » à
  /// cause de « ad ».
  static final List<String> _noiseSelectors = [
    'nav',
    'aside',
    'footer',
    '[role="navigation"]',
    '[role="banner"]',
    '[role="contentinfo"]',
    '[role="complementary"]',
    '[role="search"]',
    '.share',
    '.sharing',
    '.social',
    '.related',
    '.post-nav',
    '.advert',
    '.ads',
    '.pub',
    '.publicite',
    '.sponsored',
    '.partenaires',
    '.newsletter',
    '.subscribe',
    '.cookie-banner',
    '.cookie-notice',
    '.comments',
    '.commentaire',
    '.commentaires',
    '.related-posts',
  ];

  static final RegExp _noisePattern = RegExp(
    r'(^|[-_ ])(nav|menu|sidebar|footer|banner|promo|advert|pub|ads|'
    r'adsense|share|social|sharing|comment|comments|commentaire|'
    r'commentaires|related|recommend|newsletter|subscribe|subscription|'
    r'signup|login|cookie|consent|popup|modal|overlay|breadcrumb|'
    r'pagination|widget|toolbar|screen-reader|sr-only|visually-hidden|'
    r'copyright|sponsor|byline-share|post-nav)([-_ ]|$)',
    caseSensitive: false,
  );

  /// Conteneurs que la page déclare comme étant son contenu.
  static const List<String> _contentSelectors = [
    'article',
    'main',
    '[role="main"]',
    '.post-content',
    '.entry-content',
    '.article-content',
    '.post-body',
    '.entry-body',
    '.e-content',
    '.td-post-content',
    '#content',
    '#main',
    '.content',
  ];

  /// Balises et attributs autorisés dans le XHTML produit.
  static const Set<String> _keptTags = {
    'p',
    'br',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'ul',
    'ol',
    'li',
    'a',
    'img',
    'figure',
    'figcaption',
    'blockquote',
    'pre',
    'code',
    'em',
    'strong',
    'b',
    'i',
    'u',
    's',
    'sub',
    'sup',
    'table',
    'thead',
    'tbody',
    'tr',
    'td',
    'th',
    'span',
    'div',
    'section',
    'article',
    'main',
    'time',
    'small',
    'abbr',
    'dl',
    'dt',
    'dd',
    'hr',
    'caption',
    'colgroup',
    'col',
  };

  static const Map<String, Set<String>> _keptAttributes = {
    'a': {'href', 'title'},
    'img': {'src', 'alt', 'title'},
    'time': {'datetime'},
    'td': {'colspan', 'rowspan'},
    'th': {'colspan', 'rowspan', 'scope'},
    'abbr': {'title'},
    'blockquote': {'cite'},
  };

  static bool _isEventAttribute(String name) =>
      name.startsWith('on') ||
      name == 'style' ||
      name.startsWith('data-') ||
      name.startsWith('x-') ||
      name.startsWith('@') ||
      name == 'srcset' ||
      name == 'integrity' ||
      name == 'crossorigin' ||
      name == 'id' ||
      name == 'class';

  /// Nettoie le document et en renvoie le contenu principal, en XHTML prêt à
  /// entrer dans un chapitre d'EPUB. `baseUrl` sert à rendre les liens et les
  /// images absolus : sans cela le livre serait plein de liens morts.
  static String extract(String html, {String baseUrl = ''}) {
    final document = html_parser.parse(html);
    final base = Uri.tryParse(baseUrl);

    _removeNoise(document);

    final root = _bestRoot(document);
    if (root == null) return '';

    for (final comment in root.nodes.whereType<Comment>().toList()) {
      comment.remove();
    }

    _cleanNode(root);
    for (final node in root.querySelectorAll('*')) {
      _cleanNode(node);
    }
    if (base != null) _resolveUrls(root, base);

    return root.innerHtml.trim();
  }

  static void _cleanNode(Element node) {
    _cleanAttributes(node);
    if (_matchesNoise(node)) {
      node.remove();
      return;
    }
    if (!_keptTags.contains(node.localName)) _unwrap(node);
  }

  /// Choisis le nœud qui porte le texte. Exposé pour les tests de diagnostic.
  static Element? bestRootFor(Document document) => _bestRoot(document);

  static void _removeNoise(Document document) {
    for (final node in document.querySelectorAll(_strippedTags.join(','))) {
      node.remove();
    }
    for (final selector in _noiseSelectors) {
      for (final node in document.querySelectorAll(selector)) {
        node.remove();
      }
    }
  }

  /// Choisit le nœud qui porte le texte : un conteneur déclaré s'il en existe un
  /// de sérieux, sinon le meilleur bloc noté.
  static Element? _bestRoot(Document document) {
    Element? best;
    var bestScore = 0.0;

    for (final node in document.querySelectorAll(_contentSelectors.join(','))) {
      if (_matchesNoise(node)) continue;
      final s = score(node);
      if (s > bestScore) {
        bestScore = s;
        best = node;
      }
    }
    if (best != null && textOf(best).length >= 200) return best;

    Element? fallback;
    var fallbackScore = 0.0;
    for (final node in document.querySelectorAll(_keptTags.join(','))) {
      if (_matchesNoise(node)) continue;
      final s = score(node);
      if (s > fallbackScore) {
        fallbackScore = s;
        fallback = node;
      }
    }
    // Un conteneur déclaré trop maigre ne vaut rien : on repasse au score.
    return best != null && textOf(best).length >= 200 ? best : fallback;
  }

  static bool _matchesNoise(Element node) {
    final identity = <String>[
      if (node.id.isNotEmpty) node.id,
      ...node.classes,
    ].join(' ');

    if (identity.isEmpty) return false;

    final normalized = identity.replaceAll(RegExp(r'[-\s_]+'), ' ').trim();
    if (_contentPattern.hasMatch(normalized)) return false;
    return _noisePattern.hasMatch(normalized);
  }

  static final RegExp _contentPattern = RegExp(
    r'(^| )((post|entry|article|page|main|body|content|text|prose|story|'
    r'markdown|blog)( |$))',
    caseSensitive: false,
  );

  /// Score de densité : beaucoup de texte, peu de liens, peu d'attributs.
  static double score(Element node) {
    final text = textOf(node);
    if (text.isEmpty) return 0;

    final paragraphs = node.querySelectorAll('p, pre, blockquote, li').length;
    final links = node.querySelectorAll('a').length;
    final commas = ','.allMatches(text).length;

    var score = 1.0 + text.length / 100.0;
    score += paragraphs * 3.0;
    score += commas * 0.5;
    score += _semanticBonus(node.localName ?? '');

    final linkLength = node
        .querySelectorAll('a')
        .fold<int>(0, (sum, a) => sum + textOf(a).length);
    if (linkLength > 0) {
      score -= (linkLength / text.length) * 8;
    }

    // Un bloc entièrement constitué de liens est un sommaire, pas du texte.
    if (links > 12 && text.length / links < 40) score *= 0.3;

    final identity = [node.id, ...node.classes].whereType<String>().join(' ');
    if (identity.isNotEmpty && _noisePattern.hasMatch(identity)) score *= 0.1;

    return math.max(score, 0);
  }

  static double _semanticBonus(String tag) => switch (tag) {
    'article' => 25,
    'main' => 20,
    'section' => 4,
    'div' => 2,
    _ => 0,
  };

  static String textOf(Element node) =>
      node.text.replaceAll(RegExp(r'\s+'), ' ').trim();

  static void _cleanAttributes(Element node) {
    for (final name in node.attributes.keys.toList()) {
      final attribute = name as String;
      if (_isEventAttribute(attribute) ||
          !(_keptAttributes[node.localName]?.contains(attribute) ?? false)) {
        node.attributes.remove(attribute);
      }
    }
  }

  /// Une balise hors XHTML est déplacée vers l'intérieur : ses enfants sont
  /// conservés, la balise disparaît.
  static void _unwrap(Element node) {
    final parent = node.parent;
    if (parent == null) {
      node.remove();
      return;
    }
    // Les enfants sont insérés *avant* le nœud, qui est retiré ensuite :
    /// l'inverse donnerait un index -1.
    for (final child in node.nodes.toList()) {
      child.remove();
      parent.insertBefore(child, node);
    }
    node.remove();
  }

  static void _resolveUrls(Element root, Uri base) {
    for (final anchor in root.querySelectorAll('a')) {
      final href = anchor.attributes['href'];
      if (href == null || href.isEmpty) continue;
      if (href.startsWith('#')) {
        anchor.attributes.remove('href');
        continue;
      }
      anchor.attributes['href'] = base.resolve(href).toString();
    }
    for (final image in root.querySelectorAll('img')) {
      final src = image.attributes['src'];
      if (src == null || src.isEmpty) continue;
      image.attributes['src'] = base.resolve(src).toString();
    }
  }

  /// Texte brut, pour décider s'il y a vraiment de quoi faire un chapitre.
  static String plainText(String xhtml) {
    final document = html_parser.parse(xhtml);
    return textOf(document.body ?? document.documentElement!);
  }
}
