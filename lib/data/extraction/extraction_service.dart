import 'package:articles_kindle/data/extraction/readability.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Ce qu'on garde d'un article.
class ExtractedArticle extends ExtractionOutcome {
  ExtractedArticle({
    required this.title,
    required this.contentHtml,
    required this.plainText,
    this.author,
    this.siteName,
    this.publishedAt,
    this.leadingImage,
  });

  final String? title;
  final String? author;
  final String? siteName;
  final DateTime? publishedAt;

  /// XHTML nettoyé, prêt pour un chapitre d'EPUB.
  final String contentHtml;

  /// Le même contenu sans balise, pour décider s'il y a de quoi faire un livre.
  final String plainText;

  final String? leadingImage;
}

/// Ce que l'extraction peut rendre : un article, ou une raison d'échec.
sealed class ExtractionOutcome {}

/// Raison pour laquelle une page n'a pas donné d'article.
class ExtractionFailure extends ExtractionOutcome implements Exception {
  ExtractionFailure(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

/// Extraction d'une page déjà téléchargée et d'une page qu'il faut aller chercher.
///
/// Cette classe ne fait aucun appel réseau dans `extract` : elle transforme un
/// HTML en article. C'est `fetchAndExtract` qui va chercher la page, et c'est le
/// seul point où l'on touche au réseau.
class ExtractionService {
  ExtractionService(this._fetcher);

  final ArticleFetcher _fetcher;

  /// Page déjà en mémoire. Ne lève jamais : une page sans contenu exploitable
  /// est un résultat, pas une exception — l'appelant affiche « Réessayer ».
  ExtractionOutcome extract(FetchedPage page) {
    final contentHtml = Readability.extract(page.body, baseUrl: page.url);
    final text = Readability.plainText(contentHtml);

    if (text.length < Readability.minimumTextLength) {
      return ExtractionFailure('Aucun contenu exploitable');
    }

    final document = html_parser.parse(page.body);
    final meta = _readMetadata(document);

    return ExtractedArticle(
      title: _cleanTitle(meta.title, document, page.url),
      author: meta.author,
      siteName: meta.siteName,
      publishedAt: meta.publishedAt,
      contentHtml: contentHtml,
      plainText: text,
      leadingImage: meta.image,
    );
  }

  /// Télécharge puis extrait. Les erreurs réseau sont traduites en
  /// [ExtractionFailure] pour que l'appelant n'ait qu'un cas à traiter.
  Future<ExtractionOutcome> fetchAndExtract(String url) async {
    final FetchedPage page;
    try {
      page = await _fetcher.get(url);
    } on FetchFailure catch (e) {
      return ExtractionFailure(e.message);
    }
    return extract(page);
  }

  _Metadata _readMetadata(Document document) {
    String? title;
    String? author;
    String? siteName;
    String? image;
    DateTime? publishedAt;

    for (final meta in document.querySelectorAll('meta')) {
      final key = (meta.attributes['property'] ?? meta.attributes['name'] ?? '')
          .toLowerCase();
      final value = meta.attributes['content'];
      if (value == null || value.trim().isEmpty) continue;

      switch (key) {
        case 'og:title' || 'twitter:title':
          title ??= value.trim();
        case 'og:site_name':
          siteName ??= value.trim();
        case 'author' || 'article:author' || 'twitter:creator':
          author ??= value.trim();
        case 'article:published_time' || 'og:article:published_time':
          publishedAt ??= DateTime.tryParse(value.trim());
        case 'date' || 'pubdate' || 'dc.date':
          publishedAt ??= _parseDate(value);
        case 'og:image' || 'twitter:image':
          image ??= value.trim();
      }
    }

    title ??= document.querySelector('h1')?.text.trim();
    title ??= document.querySelector('title')?.text.trim();

    return _Metadata(
      title: title,
      author: author,
      siteName: siteName,
      image: image,
      publishedAt: publishedAt,
    );
  }

  /// `<title>Korben.info - Un article</title>` : le nom du site ne fait pas
  /// partie du titre du chapitre.
  String? _cleanTitle(String? raw, Document document, String pageUrl) {
    if (raw == null || raw.trim().isEmpty) return null;

    var title = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

    final host = Uri.tryParse(pageUrl)?.host ?? '';
    final separators = [
      for (final pattern in [' - ', ' | ', ' – ', ' — ', ' :: ', ': ']) pattern,
    ];

    for (final separator in separators) {
      final index = title.indexOf(separator);
      if (index <= 0) continue;
      final head = title.substring(0, index).trim().toLowerCase();
      final tail = title.substring(index + separator.length).trim();
      if (tail.isEmpty) continue;

      final headMatchesHost =
          host.isNotEmpty &&
          head.replaceAll(RegExp(r'^www\.'), '') == host.toLowerCase();
      final headIsShort = head.length <= 30;
      if (headMatchesHost || (headIsShort && head.split(' ').length <= 4)) {
        title = tail;
        break;
      }
    }

    title = title.trim();
    return title.isEmpty ? null : title;
  }

  static DateTime? _parseDate(String value) {
    final iso = DateTime.tryParse(value.trim());
    if (iso != null) return iso;

    final rfc822 = RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})').firstMatch(value);
    if (rfc822 == null) return null;

    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final month = months[rfc822.group(2)!.toLowerCase()];
    if (month == null) return null;
    return DateTime(
      int.parse(rfc822.group(3)!),
      month,
      int.parse(rfc822.group(1)!),
    );
  }
}

class _Metadata {
  const _Metadata({
    this.title,
    this.author,
    this.siteName,
    this.image,
    this.publishedAt,
  });

  final String? title;
  final String? author;
  final String? siteName;
  final String? image;
  final DateTime? publishedAt;
}
