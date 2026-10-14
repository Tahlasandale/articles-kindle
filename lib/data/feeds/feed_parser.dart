import 'package:xml/xml.dart';

enum FeedFormat { rss, atom }

/// Un élément de flux. `content` n'est renseigné que si le flux portait déjà le
/// texte complet ; sinon il faudra télécharger la page.
class FeedItem {
  const FeedItem({
    required this.title,
    required this.url,
    this.summary,
    this.content,
    this.author,
    this.publishedAt,
    this.mimeType,
    this.media = false,
  });

  final String title;
  final String url;
  final String? summary;

  /// Texte complet fourni par le flux (`content:encoded`).
  final String? content;
  final String? author;
  final DateTime? publishedAt;

  /// Type MIME de la pièce jointe ou du média, quand le flux en déclare un.
  final String? mimeType;

  /// Type MIME de la pièce jointe ou du média, quand le flux en déclare un.
  final bool media;

  bool get hasFullContent => (content?.trim().isNotEmpty) ?? false;

  bool get isAudio => media && _looksAudio;
  bool get isVideo => media && !_looksAudio;

  String get _mime => (mimeType ?? '').toLowerCase();

  /// YouTube et consorts déclarent `application/x-shockwave-flash`, pas `video/*` :
  /// on se fie aussi à l'adresse quand le type ne dit rien.
  bool get _looksAudio =>
      _mime.startsWith('audio/') ||
      url.endsWith('.mp3') ||
      url.endsWith('.m4a') ||
      url.endsWith('.ogg');

  /// Un podcast ou une vidéo ne fabrique pas de chapitre de lecture.
  bool get isReadable => !isAudio && !isVideo;
}

class Feed {
  const Feed({required this.title, required this.siteUrl, required this.items});

  final String title;
  final String siteUrl;
  final List<FeedItem> items;

  /// Un flux qui ne contient que de l'audio ou de la vidéo n'est pas une source
  /// d'articles : on le dit plutôt que de proposer des chapitres vides.
  bool get isMostlyMedia =>
      items.isNotEmpty && items.every((i) => !i.isReadable);
}

/// Lecture de flux RSS 2.0 et Atom.
///
/// Écrit sur `xml` plutôt que sur `webfeed_plus`, figé depuis 2024 et incapable
/// de revalider un flux (voir DECISIONS.md).
class FeedParser {
  FeedParser._();

  static FeedFormat? detectFormat(String xml) {
    final trimmed = xml.trimLeft();
    if (trimmed.startsWith('<?xml')) {
      final end = xml.indexOf('?>');
      if (end > 0) {
        final declaration = xml.substring(5, end);
        if (declaration.contains('encoding')) {
          // peu importe : l'encodage est déjà décodé en UTF-8 à la lecture
        }
      }
    }
    final root = _rootOf(xml);
    if (root == null) return null;
    return switch (root.name.local) {
      'rss' || 'rdf' => FeedFormat.rss,
      'feed' => FeedFormat.atom,
      _ => null,
    };
  }

  /// Renvoie null si le document n'est pas un flux lisible : mieux vaut une
  /// discovery qui dit « pas de flux » qu'une exception.
  static Feed? parse(String xml) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xml);
    } on XmlException {
      return null;
    }

    final root = document.rootElement;
    return switch (root.name.local) {
      'rss' => _parseRss(root),
      'feed' => _parseAtom(root),
      _ => null,
    };
  }

  static XmlElement? _rootOf(String xml) {
    try {
      return XmlDocument.parse(xml).rootElement;
    } on XmlException {
      return null;
    }
  }

  static Feed? _parseRss(XmlElement root) {
    final channel = root.getElement('channel');
    if (channel == null) return null;

    final items = <FeedItem>[];
    for (final item in channel.findElements('item')) {
      final link = _text(item, 'link');
      final guid = _text(item, 'guid');
      final url = _absolute(link ?? guid ?? '');
      if (url.isEmpty) continue;

      final full = _firstText(item, const ['content:encoded', 'content']);

      final enclosure = item.getElement('enclosure');
      final mediaContent = item.getElement('media:content');
      final mimeType =
          enclosure?.getAttribute('type') ?? mediaContent?.getAttribute('type');

      items.add(
        FeedItem(
          title: _text(item, 'title') ?? url,
          url: url,
          summary: _text(item, 'description'),
          content: full,
          author: _text(item, 'dc:creator') ?? _text(item, 'author'),
          publishedAt: _parseDate(_text(item, 'pubDate')),
          mimeType: mimeType,
          media: enclosure != null || mediaContent != null,
        ),
      );
    }

    return Feed(
      title: _text(channel, 'title') ?? '',
      siteUrl: _text(channel, 'link') ?? '',
      items: items,
    );
  }

  static Feed? _parseAtom(XmlElement root) {
    final siteUrl =
        root
            .findElements('link')
            .where((l) => l.getAttribute('rel') == null)
            .firstOrNull
            ?.getAttribute('href') ??
        '';

    final items = <FeedItem>[];
    for (final entry in root.findElements('entry')) {
      final link =
          entry
              .findElements('link')
              .where((l) => l.getAttribute('rel') == null)
              .firstOrNull
              ?.getAttribute('href') ??
          '';
      final id = _text(entry, 'id') ?? '';
      final url = _absolute(link.isNotEmpty ? link : id);
      if (url.isEmpty) continue;

      final author = entry.getElement('author')?.getElement('name')?.innerText;

      items.add(
        FeedItem(
          title: _text(entry, 'title') ?? url,
          url: url,
          summary: _text(entry, 'summary') ?? _text(entry, 'content'),
          content: null,
          author: author,
          publishedAt: _parseDate(
            _text(entry, 'published') ?? _text(entry, 'updated'),
          ),
        ),
      );
    }

    return Feed(
      title: _text(root, 'title') ?? '',
      siteUrl: siteUrl,
      items: items,
    );
  }

  /// Cherche un élément en ignorant le préfixe d'espace de noms : le flux peut
  /// déclarer `content:encoded`, `c:encoded` ou ne pas avoir de préfixe du tout.
  static String? _firstText(XmlElement parent, List<String> names) {
    for (final name in names) {
      final local = name.contains(':') ? name.split(':').last : name;
      for (final child in parent.childElements) {
        if (child.name.local == local) {
          final text = child.innerText.trim();
          if (text.isNotEmpty) return text;
        }
      }
    }
    return null;
  }

  static String? _text(XmlElement parent, String name) {
    final local = name.contains(':') ? name.split(':').last : name;
    for (final child in parent.childElements) {
      if (child.name.local == local) {
        return child.innerText.trim();
      }
    }
    return null;
  }

  static const _months = {
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

  /// `pubDate` est au format RFC 822 (« Mon, 12 Oct 2026 08:30:00 +0000 »),
  /// Atom est en ISO 8601. `DateTime.parse` ne lit aucun des deux de façon fiable.
  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    final rfc822 = _rfc822Pattern.firstMatch(value);
    if (rfc822 != null) {
      final day = int.parse(rfc822.group(1)!);
      final month = _months[rfc822.group(2)!.toLowerCase()];
      final year = int.parse(rfc822.group(3)!);
      final hour = int.parse(rfc822.group(4)!);
      final minute = int.parse(rfc822.group(5)!);
      final second = int.parse(rfc822.group(6)!);
      final offset = rfc822.group(7)!;
      if (month == null) return null;

      final utc = DateTime.utc(year, month, day, hour, minute, second);
      if (offset == 'Z') return utc;
      final sign = offset.startsWith('-') ? -1 : 1;
      final digits = offset.substring(1).replaceAll(':', '');
      final offsetHours = int.tryParse(digits.substring(0, 2)) ?? 0;
      final offsetMinutes = int.tryParse(digits.substring(2, 4)) ?? 0;
      return utc.subtract(
        Duration(hours: sign * offsetHours, minutes: sign * offsetMinutes),
      );
    }

    return DateTime.tryParse(value);
  }

  static final _rfc822Pattern = RegExp(
    r'(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|Z|UT|GMT)?',
  );

  static String _absolute(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '';
  }
}
