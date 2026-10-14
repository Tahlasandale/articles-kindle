import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/url/url_normalizer.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addArticle(String url, {String? title, ArticleStatus? status}) {
    return db
        .into(db.articles)
        .insert(
          ArticlesCompanion.insert(
            url: UrlNormalizer.normalize(url),
            title: Value(title),
            status: Value((status ?? ArticleStatus.pending).name),
          ),
        );
  }

  group('articles', () {
    test('un article entre en attente par défaut', () async {
      await addArticle('https://exemple.fr/a', title: 'Un article');
      final row = await db.select(db.articles).getSingle();
      expect(row.status, ArticleStatus.pending.name);
      expect(row.origin, ArticleOrigin.manual.name);
      expect(row.selected, isTrue);
      expect(row.sortIndex, 0);
    });

    test('l\'adresse normalisée est unique', () async {
      await addArticle('https://www.exemple.fr/a?utm_source=rss');
      await expectLater(
        addArticle('https://exemple.fr/a'),
        throwsA(isA<Exception>()),
      );
    });

    test('on retrouve un article par son adresse canonique', () async {
      await addArticle('https://www.exemple.fr/a?utm_source=rss#haut');
      final found = await (db.select(
        db.articles,
      )..where((a) => a.url.equals('https://exemple.fr/a'))).getSingle();
      expect(found.url, 'https://exemple.fr/a');
    });

    test('la liste de la file est ordonnée par sort_index', () async {
      await db
          .into(db.articles)
          .insert(
            ArticlesCompanion.insert(
              url: 'https://exemple.fr/b',
              sortIndex: const Value(2),
            ),
          );
      await db
          .into(db.articles)
          .insert(
            ArticlesCompanion.insert(
              url: 'https://exemple.fr/a',
              sortIndex: const Value(0),
            ),
          );
      await db
          .into(db.articles)
          .insert(
            ArticlesCompanion.insert(
              url: 'https://exemple.fr/c',
              sortIndex: const Value(1),
            ),
          );
      final rows = await (db.select(
        db.articles,
      )..orderBy([(a) => OrderingTerm.asc(a.sortIndex)])).get();
      expect(rows.map((r) => r.url), [
        'https://exemple.fr/a',
        'https://exemple.fr/c',
        'https://exemple.fr/b',
      ]);
    });

    test('supprimer un article efface ses étiquettes et ses images', () async {
      final id = await addArticle('https://exemple.fr/a');
      await db.into(db.tags).insert(TagsCompanion.insert(name: 'veille'));
      final tag = await db.select(db.tags).getSingle();
      await db
          .into(db.articleTags)
          .insert(ArticleTagsCompanion.insert(articleId: id, tagId: tag.id));
      await db
          .into(db.articleImages)
          .insert(
            ArticleImagesCompanion.insert(
              articleId: id,
              sourceUrl: 'https://exemple.fr/i.png',
              localPath: '/tmp/i.png',
            ),
          );

      await (db.delete(db.articles)..where((a) => a.id.equals(id))).go();

      expect(await db.select(db.articleTags).get(), isEmpty);
      expect(await db.select(db.articleImages).get(), isEmpty);
      // L'étiquette elle-même survit : elle peut servir à d'autres articles.
      expect(await db.select(db.tags).get(), hasLength(1));
    });

    test('marquer un envoi enregistre la date et passe à sent', () async {
      final id = await addArticle(
        'https://exemple.fr/a',
        status: ArticleStatus.ready,
      );
      final when = DateTime(2026, 10, 14, 9, 30);
      await (db.update(db.articles)..where((a) => a.id.equals(id))).write(
        ArticlesCompanion(
          status: Value(ArticleStatus.sent.name),
          sentAt: Value(when),
        ),
      );
      final row = await db.select(db.articles).getSingle();
      expect(row.status, ArticleStatus.sent.name);
      expect(row.sentAt, when);
    });
  });

  group('étiquettes', () {
    test('une étiquette ne peut pas être créée deux fois', () async {
      await db.into(db.tags).insert(TagsCompanion.insert(name: 'veille'));
      await expectLater(
        db.into(db.tags).insert(TagsCompanion.insert(name: 'veille')),
        throwsA(isA<Exception>()),
      );
    });

    test('un article porte plusieurs étiquettes', () async {
      final id = await addArticle('https://exemple.fr/a');
      for (final name in ['veille', 'rust']) {
        await db.into(db.tags).insert(TagsCompanion.insert(name: name));
      }
      final tags = await db.select(db.tags).get();
      for (final tag in tags) {
        await db
            .into(db.articleTags)
            .insert(ArticleTagsCompanion.insert(articleId: id, tagId: tag.id));
      }
      final linked = await db.select(db.articleTags).get();
      expect(linked, hasLength(2));
    });

    test('retirer une étiquette d\'un article laisse les autres', () async {
      final id = await addArticle('https://exemple.fr/a');
      await db.into(db.tags).insert(TagsCompanion.insert(name: 'veille'));
      await db.into(db.tags).insert(TagsCompanion.insert(name: 'rust'));
      final tags = await db.select(db.tags).get();

      await (db.delete(
        db.articleTags,
      )..where((t) => t.articleId.equals(id))).go();
      await db
          .into(db.articleTags)
          .insert(
            ArticleTagsCompanion.insert(articleId: id, tagId: tags[1].id),
          );

      final linked = await db.select(db.articleTags).get();
      expect(linked.single.tagId, tags[1].id);
    });
  });

  group('réglages', () {
    test('une clé se lit et se remplace', () async {
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'theme', value: 'light'));
      await (db.update(db.settings)..where((s) => s.key.equals('theme'))).write(
        const SettingsCompanion(value: Value('dark')),
      );
      final row = await db.select(db.settings).getSingle();
      expect(row.value, 'dark');
    });
  });

  group('livraisons', () {
    test('un envoi réussi et un échec sont tous deux conservés', () async {
      await db
          .into(db.deliveries)
          .insert(
            DeliveriesCompanion.insert(articleCount: 3, fileSize: 1200000),
          );
      await db
          .into(db.deliveries)
          .insert(
            DeliveriesCompanion.insert(
              articleCount: 0,
              fileSize: 0,
              success: const Value(false),
              error: const Value('Authentification refusée'),
            ),
          );
      final rows = await db.select(db.deliveries).get();
      expect(rows, hasLength(2));
      expect(rows.where((r) => r.success), hasLength(1));
      expect(
        rows.firstWhere((r) => !r.success).error,
        'Authentification refusée',
      );
    });
  });

  group('nom du fichier EPUB', () {
    test('accentue ni espace dans le nom', () {
      expect(
        epubFileName('Lectures du 14/10/2026'),
        'lectures-du-14-10-2026.epub',
      );
    });

    test('ajoute le numéro de partie quand le livre est découpé', () {
      expect(
        epubFileName('Lectures du 14/10/2026', part: 0, partCount: 3),
        'lectures-du-14-10-2026-1sur3.epub',
      );
    });

    test('retombe sur un nom utilisable si le titre est vide', () {
      expect(epubFileName('   '), 'lectures.epub');
    });
  });
}
