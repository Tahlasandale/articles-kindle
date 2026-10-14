import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/extraction/article_extraction_job.dart';
import 'package:articles_kindle/data/extraction/extraction_service.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubFetcher implements ArticleFetcher {
  _StubFetcher(this.pages);

  final Map<String, String> pages;

  @override
  Future<FetchedPage> get(String url) async {
    final body = pages[url];
    if (body == null) throw const FetchStatusError(404);
    return FetchedPage(url: url, body: body);
  }
}

void main() {
  late AppDatabase db;
  late ArticleService articles;

  const longText =
      'Un paragraphe de longueur normale, avec une virgule, qui explique quelque '
      'chose au lecteur de l\'article et l\'éclaire sur le sujet. ';

  String page({String title = 'Un article'}) =>
      '''
<html><head><title>$title</title>
<meta name="author" content="Quelqu'un"></head>
<body><article><p>${List.filled(10, longText).join()}</p></article></body></html>''';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    articles = ArticleService(db);
  });
  tearDown(() => db.close());

  Future<int> seed(String url) async {
    final result = await articles.addUrl(url);
    return (result as ArticleAdded).article.id;
  }

  Future<ArticleRow> row(int id) =>
      (db.select(db.articles)..where((a) => a.id.equals(id))).getSingle();

  test('un article extrait passe à ready avec son contenu', () async {
    final id = await seed('https://exemple.fr/a');
    final job = ArticleExtractionJob(
      articles,
      ExtractionService(_StubFetcher({'https://exemple.fr/a': page()})),
    );

    final outcome = await job.process(id);

    expect(outcome, isA<ExtractedArticle>());
    final result = await row(id);
    expect(result.status, 'ready');
    expect(result.title, 'Un article');
    expect(result.author, 'Quelqu\'un');
    expect(result.contentHtml, contains('<p>'));
    expect(result.contentSource, 'page');
    expect(result.error, isNull);
  });

  test('un article inaccessible passe à failed sans contenu', () async {
    final id = await seed('https://exemple.fr/404');
    final job = ArticleExtractionJob(
      articles,
      ExtractionService(_StubFetcher({})),
    );

    final outcome = await job.process(id);

    expect(outcome, isA<ExtractionFailure>());
    final result = await row(id);
    expect(result.status, 'failed');
    expect(result.error, isNotNull);
    expect(result.contentHtml, isNull);
    expect(
      result.selected,
      isTrue,
      reason: 'un échec reste cochable pour réessayer',
    );
  });

  test('le contenu déjà prêt est conservé si une relance échoue', () async {
    final id = await seed('https://exemple.fr/a');
    final job = ArticleExtractionJob(
      articles,
      ExtractionService(_StubFetcher({'https://exemple.fr/a': page()})),
    );
    await job.process(id);
    final before = (await row(id)).contentHtml;

    // Le site tombe en panne entre deux extractions.
    final offline = ArticleExtractionJob(
      articles,
      ExtractionService(_StubFetcher({})),
    );
    await offline.process(id);

    final after = await row(id);
    expect(after.status, 'failed');
    expect(
      after.contentHtml,
      before,
      reason: 'un article déjà lu reste lisible hors ligne',
    );
  });

  test('traite plusieurs articles et isole les échecs', () async {
    final good = await seed('https://exemple.fr/bon');
    final bad = await seed('https://exemple.fr/inexistant');
    final job = ArticleExtractionJob(
      articles,
      ExtractionService(_StubFetcher({'https://exemple.fr/bon': page()})),
    );

    final results = await job.processAll([good, bad]);

    expect(results[good], isA<ExtractedArticle>());
    expect(results[bad], isA<ExtractionFailure>());
    expect((await row(good)).status, 'ready');
    expect((await row(bad)).status, 'failed');
  });

  test(
    'une page dont le flux donnait déjà le texte garde la source feed',
    () async {
      final id = await seed('https://exemple.fr/a');
      final job = ArticleExtractionJob(
        articles,
        ExtractionService(_StubFetcher({'https://exemple.fr/a': page()})),
      );

      await job.process(id, fromFeedContent: '<p>Le texte du flux</p>');

      final result = await row(id);
      expect(result.contentSource, 'feed');
      expect(result.contentHtml, '<p>Le texte du flux</p>');
    },
  );
}
