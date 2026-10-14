import 'package:articles_kindle/data/feeds/feed_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const rss2 = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Korben</title>
    <link>https://korben.info/</link>
    <item>
      <title>Un article</title>
      <link>https://korben.info/un-article.html</link>
      <guid isPermaLink="true">https://korben.info/un-article.html</guid>
      <pubDate>Mon, 12 Oct 2026 08:30:00 +0000</pubDate>
      <dc:creator>Nico</dc:creator>
      <description>Résumé de l'article.</description>
    </item>
    <item>
      <title>Un autre article</title>
      <link>https://korben.info/autre.html</link>
      <guid>autre.html</guid>
      <pubDate>Sun, 11 Oct 2026 08:30:00 +0000</pubDate>
      <description><![CDATA[<p>Texte déjà en HTML.</p>]]></description>
    </item>
  </channel>
</rss>
''';

const atom = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Le mot de Jay</title>
  <link href="https://www.lemotdejay.fr/"/>
  <entry>
    <title>Une note</title>
    <link href="https://www.lemotdejay.fr/une-note/"/>
    <id>tag:lemotdejay.fr,2026:1</id>
    <published>2026-10-10T08:30:00+00:00</published>
    <author><name>Jay</name></author>
    <summary>Un résumé</summary>
  </entry>
</feed>
''';

const rssAvecContenu = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>Framablog</title>
    <link>https://framablog.org/</link>
    <item>
      <title>Un billet</title>
      <link>https://framablog.org/un-billet/</link>
      <guid>https://framablog.org/un-billet/</guid>
      <description><![CDATA[<p>Le résumé.</p>]]></description>
      <content:encoded><![CDATA[<p>Le texte complet de l'article, avec <a href="/lien">un lien</a>.</p>]]></content:encoded>
    </item>
  </channel>
</rss>
''';

const rssPodcast = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>BURGER RING</title>
    <link>https://media.rss.com/burgerring/</link>
    <item>
      <title>Épisode 12</title>
      <link>https://media.rss.com/burgerring/12</link>
      <description>Un épisode</description>
      <enclosure url="https://media.rss.com/burgerring/12.mp3" type="audio/mpeg" length="1"/>
    </item>
  </channel>
</rss>
''';

const rssVideo = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>Une chaîne</title>
    <link>https://www.youtube.com/channel/x</link>
    <item>
      <title>Une vidéo</title>
      <link>https://www.youtube.com/watch?v=abc</link>
      <media:content url="https://www.youtube.com/v/abc" type="application/x-shockwave-flash"/>
    </item>
  </channel>
</rss>
''';

void main() {
  group('type de flux', () {
    test('reconnaît RSS et Atom', () {
      expect(FeedParser.detectFormat(rss2), FeedFormat.rss);
      expect(FeedParser.detectFormat(atom), FeedFormat.atom);
    });

    test('ne devine pas sur un document inconnu', () {
      expect(FeedParser.detectFormat('<html><body>rien</body></html>'), isNull);
    });
  });

  group('RSS 2.0', () {
    late Feed feed;

    setUp(() => feed = FeedParser.parse(rss2)!);

    test('lit le titre du site et son adresse', () {
      expect(feed.title, 'Korben');
      expect(feed.siteUrl, 'https://korben.info/');
    });

    test('lit les éléments dans l\'ordre du flux', () {
      expect(feed.items.map((i) => i.title), [
        'Un article',
        'Un autre article',
      ]);
    });

    test('lit l\'adresse, l\'auteur et la date', () {
      final item = feed.items.first;
      expect(item.url, 'https://korben.info/un-article.html');
      expect(item.author, 'Nico');
      expect(item.publishedAt, DateTime.utc(2026, 10, 12, 8, 30));
    });

    test('un guid non permalien quand le lien manque', () {
      expect(feed.items.every((i) => i.url.isNotEmpty), isTrue);
    });

    test('le résumé seul n\'est pas du contenu complet', () {
      expect(feed.items.first.hasFullContent, isFalse);
      expect(feed.items.last.hasFullContent, isFalse);
      expect(feed.items.last.summary, contains('<p>Texte déjà en HTML.</p>'));
    });
  });

  group('Atom', () {
    test('lit le titre, le lien et la date', () {
      final feed = FeedParser.parse(atom)!;
      expect(feed.title, 'Le mot de Jay');
      expect(feed.siteUrl, 'https://www.lemotdejay.fr/');
      final item = feed.items.single;
      expect(item.title, 'Une note');
      expect(item.url, 'https://www.lemotdejay.fr/une-note/');
      expect(item.publishedAt, DateTime.utc(2026, 10, 10, 8, 30));
      expect(item.author, 'Jay');
    });
  });

  group('contenu complet', () {
    test('content:encoded prime sur la description', () {
      final feed = FeedParser.parse(rssAvecContenu)!;
      final item = feed.items.single;
      expect(item.hasFullContent, isTrue);
      expect(item.content, contains('Le texte complet'));
    });

    test('un flux sans content:encoded reste un candidat à extraire', () {
      final feed = FeedParser.parse(rss2)!;
      expect(feed.items.every((i) => !i.hasFullContent), isTrue);
    });
  });

  group('flux non textuels', () {
    test('un podcast ne donne aucun article', () {
      final feed = FeedParser.parse(rssPodcast)!;
      expect(feed.items.single.isAudio, isTrue);
      expect(feed.isMostlyMedia, isTrue);
    });

    test('une vidéo est écartée', () {
      final feed = FeedParser.parse(rssVideo)!;
      expect(feed.items.single.isVideo, isTrue);
    });

    test('un flux d\'articles n\'est pas marqué média', () {
      expect(FeedParser.parse(rss2)!.isMostlyMedia, isFalse);
    });
  });

  group('robustesse', () {
    test('un flux mal formé renvoie null plutôt que de lever', () {
      expect(FeedParser.parse('<rss><channel><item></channel>'), isNull);
    });

    test('un flux vide est un flux valide sans article', () {
      final feed = FeedParser.parse(
        '<rss version="2.0"><channel><title>Vide</title></channel></rss>',
      );
      expect(feed, isNotNull);
      expect(feed!.items, isEmpty);
    });

    test('les dates illisibles ne font pas échouer la lecture', () {
      const dateInvalide = '''
<rss version="2.0"><channel><title>T</title>
<item><title>A</title><link>https://exemple.fr/a</link><pubDate>pas une date</pubDate></item>
</channel></rss>''';
      final feed = FeedParser.parse(dateInvalide)!;
      expect(feed.items.single.publishedAt, isNull);
    });
  });
}
