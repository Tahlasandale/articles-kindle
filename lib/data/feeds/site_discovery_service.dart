import 'package:articles_kindle/data/feeds/feed_parser.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:articles_kindle/data/url/url_normalizer.dart';
import 'package:html/parser.dart' as html_parser;

/// Cherche les articles d'un site sans s'abonner à rien.
///
/// On télécharge la page d'accueil, on trouve le flux qu'elle déclare, on lit le
/// flux. Rien n'est enregistré : l'utilisateur voit la liste et choisit.
class SiteDiscoveryService {
  SiteDiscoveryService(this._fetcher);

  final ArticleFetcher _fetcher;

  Future<DiscoveryResult> discover(String siteUrl) async {
    final String pageUrl;
    try {
      pageUrl = UrlNormalizer.normalize(siteUrl);
    } on FormatException catch (e) {
      return DiscoveryInvalid(e.message);
    }

    final FetchedPage page;
    try {
      page = await _fetcher.get(pageUrl);
    } on FetchFailure catch (e) {
      return DiscoveryUnreachable(e.message);
    }

    final feedUrl = _findFeedUrl(page.body, page.url);
    if (feedUrl == null) {
      return const DiscoveryNoFeed();
    }

    final FetchedPage feedPage;
    try {
      feedPage = await _fetcher.get(feedUrl);
    } on FetchFailure catch (e) {
      return DiscoveryUnreachable(e.message);
    }

    final feed = FeedParser.parse(feedPage.body);
    if (feed == null) {
      return const DiscoveryNoFeed();
    }
    if (feed.isMostlyMedia) {
      return const DiscoveryMediaOnly();
    }

    final articles = feed.items.where((i) => i.isReadable).toList();
    return DiscoveryFound(
      feedUrl: feedUrl,
      siteName: feed.title.isNotEmpty ? feed.title : Uri.parse(feedUrl).host,
      siteUrl: feed.siteUrl.isNotEmpty ? feed.siteUrl : page.url,
      items: articles,
    );
  }

  /// `<link rel="alternate" type="application/rss+xml">` d'abord, puis un lien
  /// dont le texte ou l'adresse contient « rss » ou « feed ».
  static String? _findFeedUrl(String body, String pageUrl) {
    final document = html_parser.parse(body);

    for (final link in document.querySelectorAll('link[rel="alternate"]')) {
      final type = link.attributes['type']?.toLowerCase() ?? '';
      if (type.contains('rss') || type.contains('atom')) {
        final href = link.attributes['href'];
        if (href != null && href.isNotEmpty) {
          return Uri.parse(pageUrl).resolve(href).toString();
        }
      }
    }

    for (final anchor in document.querySelectorAll('a[href]')) {
      final href = anchor.attributes['href'] ?? '';
      final text = anchor.text.toLowerCase();
      final haystack = '$href $text';
      if (haystack.contains('rss') ||
          haystack.contains('feed') ||
          haystack.contains('/atom')) {
        if (href.startsWith('http') || href.startsWith('/')) {
          return Uri.parse(pageUrl).resolve(href).toString();
        }
      }
    }

    return null;
  }
}

/// Outcome de la découverte, typé pour que l'écran n'ait qu'une chose à traiter.
sealed class DiscoveryResult {
  const DiscoveryResult();

  String? get siteName => null;
  List<FeedItem> get items => const [];
}

class DiscoveryFound extends DiscoveryResult {
  const DiscoveryFound({
    required this.feedUrl,
    required this.siteName,
    required this.siteUrl,
    required this.items,
  });

  final String feedUrl;
  final String siteUrl;
  @override
  final String siteName;
  @override
  final List<FeedItem> items;
}

class DiscoveryNoFeed extends DiscoveryResult {
  const DiscoveryNoFeed();
}

class DiscoveryMediaOnly extends DiscoveryResult {
  const DiscoveryMediaOnly();
}

class DiscoveryUnreachable extends DiscoveryResult {
  const DiscoveryUnreachable(this.reason);
  final String reason;
}

class DiscoveryInvalid extends DiscoveryResult {
  const DiscoveryInvalid(this.reason);
  final String reason;
}
