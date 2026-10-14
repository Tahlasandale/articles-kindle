import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base ouverte. Les tests la remplacent par une base en mémoire.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final articleServiceProvider = Provider<ArticleService>(
  (ref) => ArticleService(ref.watch(databaseProvider)),
);

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(databaseProvider)),
);

/// Réglages de l'application, rechargés au démarrage.
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.watch(settingsStoreProvider).load();

  /// Modifie un réglage et l'écrit immédiatement.
  Future<void> edit(AppSettings Function(AppSettings) change) async {
    final current = state.value ?? const AppSettings();
    final next = change(current);
    state = AsyncData(next);
    await ref.read(settingsStoreProvider).save(next);
  }

  /// Bascule clair → sombre → système. Le choix est mémorisé.
  Future<void> cycleTheme() => update(
    (s) => s.copyWith(
      themeMode: switch (s.themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      },
    ),
  );
}

final settingsProvider = AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Les réglages du moment, sans attente : l'interface n'a pas besoin de:flutter
/// pour choisir un thème.
final currentSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(settingsProvider).value ?? const AppSettings(),
);

final articlesProvider = StreamProvider<List<ArticleRow>>(
  (ref) => ref.watch(articleServiceProvider).watchAll(),
);

final sentArticlesProvider = StreamProvider<List<ArticleRow>>(
  (ref) => ref.watch(articleServiceProvider).watchSent(),
);

final deliveriesProvider = StreamProvider<List<DeliveryRow>>(
  (ref) => ref.watch(articleServiceProvider).watchDeliveries(),
);

/// Ce qui part dans le prochain livre.
final sendQueueProvider = FutureProvider<List<ArticleRow>>(
  (ref) => ref.watch(articleServiceProvider).sendQueue(),
);
