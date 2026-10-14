import 'package:drift/drift.dart';

/// Cycle de vie d'un article.
///
/// `pending → ready → sent`, avec `failed` rattrapable. Un article `failed` peut
/// repasser en `pending` : c'est le bouton « Réessayer ».
enum ArticleStatus {
  pending,
  ready,
  failed,
  sent;

  static ArticleStatus fromName(String name) =>
      ArticleStatus.values.firstWhere((s) => s.name == name);

  bool get isQueued => this == pending || this == ready;
}

/// Comment l'article est entré dans l'application.
enum ArticleOrigin {
  /// Menu Partager d'une autre application.
  share,

  /// Saisie manuelle dans l'onglet « À lire ».
  manual,

  /// Trouvé par « articles d'un site ».
  site;

  static ArticleOrigin fromName(String name) =>
      ArticleOrigin.values.firstWhere((o) => o.name == name);
}

/// D'où vient le texte conservé dans `contentHtml`.
enum ContentSource {
  /// La page a été téléchargée puis nettoyée.
  page,

  /// Le flux du site fournissait déjà le texte complet.
  feed;

  static ContentSource? fromName(String name) =>
      ContentSource.values.where((c) => c.name == name).firstOrNull;
}

@DataClassName('ArticleRow')
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text().unique()();
  TextColumn get title => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get siteName => text().nullable()();
  TextColumn get siteUrl => text().nullable()();

  DateTimeColumn get publishedAt => dateTime().nullable()();

  // Les valeurs par défaut sont écrites en dur : `.name` d'un enum n'est pas une
  // constante de compilation. Elles doivent rester alignées sur ArticleOrigin et
  // ArticleStatus, ce que le test de schéma vérifie.
  TextColumn get origin => text().withDefault(const Constant('manual'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get error => text().nullable()();

  /// XHTML nettoyé, prêt à entrer dans un chapitre.
  TextColumn get contentHtml => text().nullable()();
  TextColumn get contentSource => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sentAt => dateTime().nullable()();

  /// Coché pour le prochain envoi.
  BoolColumn get selected => boolean().withDefault(const Constant(true))();

  /// Ordre choisi à la main dans l'écran d'envoi.
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
}

@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('ArticleTagRow')
class ArticleTags extends Table {
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {articleId, tagId};
}

@DataClassName('ArticleImageRow')
class ArticleImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceUrl => text()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text().nullable()();
}

/// Réglages non sensibles. Le mot de passe SMTP vit dans le Keystore, jamais ici.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('DeliveryRow')
class Deliveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get articleCount => integer()();
  IntColumn get fileSize => integer()();
  BoolColumn get success => boolean().withDefault(const Constant(true))();
  TextColumn get error => text().nullable()();
}
