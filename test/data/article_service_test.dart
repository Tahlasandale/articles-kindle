import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/db/tables.dart';
// drift exporte ses propres `isNull` et `isNotNull`, qui entrent en conflit avec
// ceux de matcher.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ArticleService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = ArticleService(db);
  });
  tearDown(() => db.close());

  /// Les deux issues heureuses renvoient un article ; la troisième lève, ce qui
  /// ferait échouer le test bien plus tard et moins clairement.
  ArticleRow articleOf(AddResult result) => switch (result) {
    ArticleAdded(:final article) => article,
    ArticleAlreadyKnown(:final article) => article,
    ArticleInvalid(:final reason) => fail(
      'adresse refusée alors qu\'elle devait passer : $reason',
    ),
  };

  Future<ArticleRow> addOk(String url) async {
    final result = await service.addUrl(url, origin: ArticleOrigin.manual);
    expect(result, isA<ArticleAdded>());
    return articleOf(result);
  }

  group('addUrl', () {
    test('ajoute un article en attente', () async {
      final article = await addOk('https://exemple.fr/a');
      expect(article.url, 'https://exemple.fr/a');
      expect(article.status, ArticleStatus.pending.name);
      expect(article.origin, ArticleOrigin.manual.name);
    });

    test('enregistre l\'origine du partage', () async {
      final result = await service.addUrl(
        'https://exemple.fr/a',
        origin: ArticleOrigin.share,
      );
      expect(articleOf(result).origin, ArticleOrigin.share.name);
    });

    test('refuse une adresse invalide sans rien écrire', () async {
      final result = await service.addUrl('pas une url');
      expect(result, isA<ArticleInvalid>());
      expect(await db.select(db.articles).get(), isEmpty);
    });

    test('signale un doublon sans créer de seconde ligne', () async {
      await addOk('https://www.exemple.fr/a?utm_source=rss');
      final result = await service.addUrl('https://exemple.fr/a');
      expect(result, isA<ArticleAlreadyKnown>());
      expect(await db.select(db.articles).get(), hasLength(1));
    });

    test('le doublon renvoie l\'article déjà connu', () async {
      final first = await addOk('https://exemple.fr/a');
      final result = await service.addUrl('https://exemple.fr/a');
      expect(articleOf(result).id, first.id);
    });

    test('place le nouvel article à la fin de la file', () async {
      await addOk('https://exemple.fr/a');
      final second = await addOk('https://exemple.fr/b');
      expect(second.sortIndex, greaterThan(0));
    });
  });

  group('cycle de vie', () {
    test('markReady pose le contenu et la source', () async {
      final article = await addOk('https://exemple.fr/a');
      await service.markReady(
        article.id,
        title: 'Titre',
        author: 'Auteur',
        contentHtml: '<p>Texte</p>',
        contentSource: ContentSource.page,
      );
      final row = await (db.select(
        db.articles,
      )..where((a) => a.id.equals(article.id))).getSingle();
      expect(row.status, ArticleStatus.ready.name);
      expect(row.title, 'Titre');
      expect(row.author, 'Auteur');
      expect(row.contentHtml, '<p>Texte</p>');
      expect(row.contentSource, ContentSource.page.name);
      expect(row.error, isNull);
    });

    test('markFailed conserve un message et reste réessayable', () async {
      final article = await addOk('https://exemple.fr/a');
      await service.markFailed(article.id, error: 'Page inaccessible');
      final row = await (db.select(
        db.articles,
      )..where((a) => a.id.equals(article.id))).getSingle();
      expect(row.status, ArticleStatus.failed.name);
      expect(row.error, 'Page inaccessible');
      expect(row.selected, isTrue);
    });

    test('retry remet en attente et efface l\'erreur', () async {
      final article = await addOk('https://exemple.fr/a');
      await service.markFailed(article.id, error: 'Page inaccessible');
      await service.retry(article.id);
      final row = await (db.select(
        db.articles,
      )..where((a) => a.id.equals(article.id))).getSingle();
      expect(row.status, ArticleStatus.pending.name);
      expect(row.error, isNull);
    });

    test('markSent date l\'envoi et décoche l\'article', () async {
      final article = await addOk('https://exemple.fr/a');
      await service.markSent([article.id]);
      final row = await (db.select(
        db.articles,
      )..where((a) => a.id.equals(article.id))).getSingle();
      expect(row.status, ArticleStatus.sent.name);
      expect(row.sentAt, isNotNull);
      expect(row.selected, isFalse);
    });

    test('un échec d\'envoi ne marque rien', () async {
      final article = await addOk('https://exemple.fr/a');
      await service.markReady(article.id, contentHtml: '<p>Texte</p>');
      await service.recordDelivery(
        articleCount: 1,
        fileSize: 100,
        success: false,
        error: 'Authentification refusée',
      );
      final row = await (db.select(
        db.articles,
      )..where((a) => a.id.equals(article.id))).getSingle();
      expect(row.status, ArticleStatus.ready.name);
      expect(row.sentAt, isNull);
    });
  });

  group('sélection et ordre', () {
    test('cocher et décocher un article', () async {
      final a = await addOk('https://exemple.fr/a');
      await service.setSelected([a.id], selected: false);
      var row = await (db.select(
        db.articles,
      )..where((t) => t.id.equals(a.id))).getSingle();
      expect(row.selected, isFalse);

      await service.setSelected([a.id], selected: true);
      row = await (db.select(
        db.articles,
      )..where((t) => t.id.equals(a.id))).getSingle();
      expect(row.selected, isTrue);
    });

    test('réordonner réécrit les index dans l\'ordre demandé', () async {
      final a = await addOk('https://exemple.fr/a');
      final b = await addOk('https://exemple.fr/b');
      final c = await addOk('https://exemple.fr/c');

      await service.reorder([c.id, a.id, b.id]);

      final rows = await (db.select(
        db.articles,
      )..orderBy([(t) => OrderingTerm.asc(t.sortIndex)])).get();
      expect(rows.map((r) => r.id), [c.id, a.id, b.id]);
    });
  });

  group('file d\'envoi', () {
    test('ne liste que les articles prêts et cochés', () async {
      final a = await addOk('https://exemple.fr/a');
      final b = await addOk('https://exemple.fr/b');
      await addOk('https://exemple.fr/c');
      await service.markReady(a.id, contentHtml: '<p>a</p>');
      await service.markReady(b.id, contentHtml: '<p>b</p>');
      // c reste en attente : on ne l'envoie pas avant extraction.
      await service.setSelected([b.id], selected: false);

      final queue = await service.sendQueue();

      expect(queue.map((r) => r.id), [a.id]);
    });

    test('la liste est ordonnée par le choix de l\'utilisateur', () async {
      final a = await addOk('https://exemple.fr/a');
      final b = await addOk('https://exemple.fr/b');
      await service.markReady(a.id, contentHtml: '<p>a</p>');
      await service.markReady(b.id, contentHtml: '<p>b</p>');
      await service.reorder([b.id, a.id]);
      final queue = await service.sendQueue();
      expect(queue.map((r) => r.id), [b.id, a.id]);
    });

    test('la file exclut un article envoyé', () async {
      final a = await addOk('https://exemple.fr/a');
      await service.markReady(a.id, contentHtml: '<p>a</p>');
      await service.markSent([a.id]);
      expect(await service.sendQueue(), isEmpty);
    });

    test('watchSendQueue émet en continu lors des modifications', () async {
      final stream = service.watchSendQueue();
      final expectation = expectLater(
        stream.map((list) => list.map((a) => a.id).toList()),
        emitsInOrder([
          [], // vide initialement
          [], // article ajouté en pending
          [1], // article passé en ready
        ]),
      );

      final a = await addOk('https://exemple.fr/a');
      await service.markReady(a.id, contentHtml: '<p>a</p>');

      await expectation;
    });
  });

  group('purge', () {
    test('purge le contenu envoyé mais garde les titres', () async {
      final a = await addOk('https://exemple.fr/a');
      await service.markReady(
        a.id,
        title: 'Titre',
        contentHtml: '<p>texte</p>',
      );
      await service.markSent([a.id]);

      final purged = await service.purgeSentContent();

      expect(purged, 1);
      final row = await db.select(db.articles).getSingle();
      expect(row.title, 'Titre');
      expect(row.url, 'https://exemple.fr/a');
      expect(row.contentHtml, isNull);
      expect(row.status, ArticleStatus.sent.name);
    });

    test('ne purge pas un article non envoyé', () async {
      final a = await addOk('https://exemple.fr/a');
      await service.markReady(a.id, contentHtml: '<p>texte</p>');
      expect(await service.purgeSentContent(), 0);
      final row = await db.select(db.articles).getSingle();
      expect(row.contentHtml, '<p>texte</p>');
    });
  });

  group('réassigner dans la file', () {
    test('un article envoyé peut revenir en attente', () async {
      final a = await addOk('https://exemple.fr/a');
      await service.markReady(a.id, contentHtml: '<p>a</p>');
      await service.markSent([a.id]);
      await service.requeue([a.id]);
      final row = await db.select(db.articles).getSingle();
      expect(row.status, ArticleStatus.ready.name);
      expect(row.selected, isTrue);
      expect(row.sentAt, isNull);
    });
  });
}
