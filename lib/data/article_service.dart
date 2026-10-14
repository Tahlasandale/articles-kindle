import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/url/url_normalizer.dart';
import 'package:drift/drift.dart';

/// Issue d'un ajout. Le type distingue les cas, les tests n'ont plus à vérifier
/// un statut ni à forcer un null.
sealed class AddResult {
  const AddResult();
}

/// L'article est entré dans la file, en attente d'extraction.
class ArticleAdded extends AddResult {
  const ArticleAdded(this.article);

  final ArticleRow article;
}

/// L'adresse existe déjà : rien n'est créé, la ligne existante est renvoyée.
class ArticleAlreadyKnown extends AddResult {
  const ArticleAlreadyKnown(this.article);

  final ArticleRow article;
}

/// L'entrée n'est pas une adresse web. Rien n'est écrit en base.
class ArticleInvalid extends AddResult {
  const ArticleInvalid(this.reason);

  /// Message technique, jamais montré tel quel à l'utilisateur.
  final String reason;
}

/// Règles d'usage des articles : qui entre, dans quel état, dans quel ordre.
///
/// Aucune méthode ne touche au réseau. L'extraction appelle `markReady` ou
/// `markFailed` quand elle a fini.
class ArticleService {
  ArticleService(this._db);

  final AppDatabase _db;

  Future<AddResult> addUrl(
    String rawUrl, {
    ArticleOrigin origin = ArticleOrigin.manual,
  }) async {
    final Uri uri;
    try {
      uri = UrlNormalizer.parse(rawUrl);
    } on FormatException catch (e) {
      return ArticleInvalid(e.message);
    }

    final normalized = UrlNormalizer.normalize(rawUrl);

    final existing = await (_db.select(
      _db.articles,
    )..where((a) => a.url.equals(normalized))).getSingleOrNull();
    if (existing != null) {
      return ArticleAlreadyKnown(existing);
    }

    final nextIndex = await _nextSortIndex();
    final id = await _db
        .into(_db.articles)
        .insert(
          ArticlesCompanion.insert(
            url: normalized,
            origin: Value(origin.name),
            siteUrl: Value(_siteOf(uri)),
            sortIndex: Value(nextIndex),
          ),
        );

    final row = await (_db.select(
      _db.articles,
    )..where((a) => a.id.equals(id))).getSingle();
    return ArticleAdded(row);
  }

  Future<void> markReady(
    int id, {
    String? title,
    String? author,
    String? siteName,
    DateTime? publishedAt,
    required String contentHtml,
    ContentSource contentSource = ContentSource.page,
  }) async {
    await (_db.update(_db.articles)..where((a) => a.id.equals(id))).write(
      ArticlesCompanion(
        status: Value(ArticleStatus.ready.name),
        title: Value(title),
        author: Value(author),
        siteName: Value(siteName),
        publishedAt: Value(publishedAt),
        contentHtml: Value(contentHtml),
        contentSource: Value(contentSource.name),
        error: const Value(null),
      ),
    );
  }

  Future<void> markFailed(int id, {required String error}) async {
    await (_db.update(_db.articles)..where((a) => a.id.equals(id))).write(
      ArticlesCompanion(
        status: Value(ArticleStatus.failed.name),
        error: Value(error),
      ),
    );
  }

  Future<void> retry(int id) async {
    await (_db.update(_db.articles)..where((a) => a.id.equals(id))).write(
      ArticlesCompanion(
        status: Value(ArticleStatus.pending.name),
        error: const Value(null),
      ),
    );
  }

  Future<void> markSent(List<int> ids) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.articles)..where((a) => a.id.isIn(ids))).write(
      ArticlesCompanion(
        status: Value(ArticleStatus.sent.name),
        sentAt: Value(DateTime.now()),
        selected: const Value(false),
      ),
    );
  }

  Future<void> requeue(List<int> ids) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.articles)..where((a) => a.id.isIn(ids))).write(
      ArticlesCompanion(
        status: Value(ArticleStatus.ready.name),
        sentAt: const Value(null),
        selected: const Value(true),
        error: const Value(null),
      ),
    );
  }

  Future<void> setSelected(List<int> ids, {required bool selected}) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.articles)..where((a) => a.id.isIn(ids))).write(
      ArticlesCompanion(selected: Value(selected)),
    );
  }

  /// `orderedIds` est l'ordre choisi à l'écran d'envoi ; il réécrit `sortIndex`.
  Future<void> reorder(List<int> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (_db.update(_db.articles)..where((a) => a.id.equals(orderedIds[i])))
          .write(ArticlesCompanion(sortIndex: Value(i)));
    }
  }

  /// Ce qui part dans le livre : prêt, coché, dans l'ordre choisi.
  Future<List<ArticleRow>> sendQueue() {
    return (_db.select(_db.articles)
          ..where(
            (a) =>
                a.status.equals(ArticleStatus.ready.name) &
                a.selected.equals(true),
          )
          ..orderBy([(a) => OrderingTerm.asc(a.sortIndex)]))
        .get();
  }

  /// Tout ce qui est visible dans l'onglet « À lire ».
  Stream<List<ArticleRow>> watchAll() {
    return (_db.select(_db.articles)..orderBy([
          (a) => OrderingTerm.desc(a.createdAt),
          (a) => OrderingTerm.asc(a.id),
        ]))
        .watch();
  }

  Stream<List<ArticleRow>> watchSent() {
    return (_db.select(_db.articles)
          ..where((a) => a.status.equals(ArticleStatus.sent.name))
          ..orderBy([(a) => OrderingTerm.desc(a.sentAt)]))
        .watch();
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.articles)..where((a) => a.id.equals(id))).go();
  }

  Future<void> addTag(int articleId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final tag = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(trimmed))).getSingleOrNull();
    final tagId =
        tag?.id ??
        await _db.into(_db.tags).insert(TagsCompanion.insert(name: trimmed));
    await _db
        .into(_db.articleTags)
        .insert(
          ArticleTagsCompanion.insert(articleId: articleId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<List<TagRow>> tagsOf(int articleId) async {
    final query =
        _db.select(_db.tags).join([
            innerJoin(
              _db.articleTags,
              _db.articleTags.tagId.equalsExp(_db.tags.id),
            ),
          ])
          ..where(_db.articleTags.articleId.equals(articleId))
          ..orderBy([OrderingTerm.asc(_db.tags.name)]);
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.tags)).toList();
  }

  /// Vide le contenu des articles déjà envoyés. Renvoie le nombre d'articles touchés.
  Future<int> purgeSentContent() async {
    final affected =
        await (_db.update(
          _db.articles,
        )..where((a) => a.status.equals(ArticleStatus.sent.name))).write(
          const ArticlesCompanion(
            contentHtml: Value(null),
            contentSource: Value(null),
          ),
        );
    await _db.delete(_db.articleImages).go();
    return affected;
  }

  Future<void> recordDelivery({
    required int articleCount,
    required int fileSize,
    required bool success,
    String? error,
  }) async {
    await _db
        .into(_db.deliveries)
        .insert(
          DeliveriesCompanion.insert(
            articleCount: articleCount,
            fileSize: fileSize,
            success: Value(success),
            error: Value(error),
          ),
        );
  }

  Stream<List<DeliveryRow>> watchDeliveries() {
    return (_db.select(
      _db.deliveries,
    )..orderBy([(d) => OrderingTerm.desc(d.sentAt)])).watch();
  }

  /// Le nouvel article passe après tout ce qui est déjà dans la file.
  Future<int> _nextSortIndex() async {
    final max = _db.articles.sortIndex.max();
    final query = _db.selectOnly(_db.articles)..addColumns([max]);
    final row = await query.getSingle();
    final value = row.read(max);
    return value == null ? 0 : value + 1;
  }

  static String? _siteOf(Uri uri) => uri.host.isEmpty ? null : uri.host;
}
