import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/extraction/article_extraction_job.dart';
import 'package:articles_kindle/data/extraction/extraction_service.dart';
import 'package:articles_kindle/data/ingest.dart';
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
  late ArticleIngest ingest;

  const longText =
      'Un paragraphe de longueur normale, avec une virgule, qui explique quelque '
      'chose au lecteur de l\'article et l\'éclaire sur le sujet. ';

  String page({String title = 'Un article'}) =>
      '''
<html><head><title>$title</title></head>
<body><article><p>${List.filled(10, longText).join()}</p></article></body></html>''';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    articles = ArticleService(db);
    ingest = ArticleIngest(
      articles,
      ArticleExtractionJob(
        articles,
        ExtractionService(
          _StubFetcher({'https://exemple.fr/a': page(title: 'Le titre réel')}),
        ),
      ),
    );
  });
  tearDown(() => db.close());

  test('un lien ajouté arrive prêt, sans passer par l\'écran', () async {
    final outcome = await ingest.addAndExtract('https://exemple.fr/a');

    expect(outcome.isReady, isTrue);

    final row = await db.select(db.articles).getSingle();
    expect(row.status, 'ready');
    expect(row.title, 'Le titre réel');
    expect(row.contentHtml, isNotNull);
  });

  test('un lien mort arrive en échec, pas en attente', () async {
    final outcome = await ingest.addAndExtract('https://exemple.fr/404');

    expect(outcome.status, ArticleStatus.failed);
    expect(outcome.reason, isNotNull);

    final row = await db.select(db.articles).getSingle();
    expect(row.status, 'failed');
  });

  test('un lien déjà connu n\'est pas ré-extrait', () async {
    await ingest.addAndExtract('https://exemple.fr/a');
    final second = await ingest.addAndExtract('https://exemple.fr/a');

    expect(second.isDuplicate, isTrue);
    expect(await db.select(db.articles).get(), hasLength(1));
  });

  test('le contenu venu du flux évite le téléchargement', () async {
    // L'URL n'est pas dans le faux fetcher : seul le contenu du flux peut passer.
    final outcome = await ingest.addAndExtract(
      'https://exemple.fr/pas-telecharge',
      origin: ArticleOrigin.site,
      contentFromFeed: '<p>Le texte complet du flux.</p>',
    );

    expect(outcome.isReady, isTrue);
    final row = await db.select(db.articles).getSingle();
    expect(row.contentSource, 'feed');
    expect(row.contentHtml, '<p>Le texte complet du flux.</p>');
  });

  test('une adresse invalide n\'écrit rien', () async {
    final outcome = await ingest.addAndExtract('pas une adresse');

    expect(outcome.status, ArticleStatus.failed);
    expect(await db.select(db.articles).get(), isEmpty);
  });

  test('une série d\'articles continue malgré les échecs', () async {
    final results = await ingest.addAll([
      (url: 'https://exemple.fr/a', contentFromFeed: null),
      (url: 'https://exemple.fr/inexistant', contentFromFeed: null),
      (url: 'https://exemple.fr/b', contentFromFeed: '<p>Du flux</p>'),
    ]);

    expect(results.map((r) => r.status), [
      ArticleStatus.ready,
      ArticleStatus.failed,
      ArticleStatus.ready,
    ]);
  });
}
