import 'dart:io';

import 'package:articles_kindle/data/db/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Articles, Tags, ArticleTags, ArticleImages, Settings, Deliveries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Base en mémoire, pour les tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'articles_kindle.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Nom de fichier sous lequel un EPUB temporaire est écrit. Amazon utilise ce nom
/// comme titre du livre, donc il ne doit contenir ni accent ni espace.
String epubFileName(String bookTitle, {int? part, int? partCount}) {
  final slug = _asciiSlug(bookTitle);
  final base = slug.isEmpty ? 'lectures' : slug;
  final suffix = (part != null && partCount != null && partCount > 1)
      ? '-${part + 1}sur$partCount'
      : '';
  return '$base$suffix.epub';
}

/// Les lettres accentuées du français sont dépliées explicitement : le nom d'un
/// livre que vous lisez en français doit rester lisible dans le dossier de
/// téléchargement d'Amazon.
const Map<String, String> _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'õ': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'oe',
  'æ': 'ae',
};

String _asciiSlug(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final folded = _accents[char.toLowerCase()];
    buffer.write(folded ?? char);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '')
      .toLowerCase();
}
