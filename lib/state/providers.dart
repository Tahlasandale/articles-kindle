import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/extraction/article_extraction_job.dart';
import 'package:articles_kindle/data/extraction/extraction_service.dart';
import 'package:articles_kindle/data/images/image_downloader.dart';
import 'package:articles_kindle/data/ingest.dart';
import 'package:articles_kindle/data/mail/kindle_mailer.dart';
import 'package:articles_kindle/data/mail/mail_transport.dart';
import 'package:articles_kindle/data/mail/smtp_mail_transport.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:articles_kindle/data/share/share_receiver.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/settings.dart';
import 'package:articles_kindle/data/settings_backup_service.dart';
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

final settingsBackupServiceProvider = Provider<SettingsBackupService>(
  (ref) => SettingsBackupService(
    store: ref.watch(settingsStoreProvider),
    secrets: ref.watch(secretStoreProvider),
  ),
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

/// Point d'entrée réseau unique pour toute l'application.
final articleFetcherProvider = Provider<ArticleFetcher>(
  (ref) => DioArticleFetcher(),
);

final extractionJobProvider = Provider<ArticleExtractionJob>(
  (ref) => ArticleExtractionJob(
    ref.watch(articleServiceProvider),
    ExtractionService(ref.watch(articleFetcherProvider)),
  ),
);

final shareReceiverProvider = Provider<ShareReceiver>((ref) => ShareReceiver());

final ingestProvider = Provider<ArticleIngest>(
  (ref) => ArticleIngest(
    ref.watch(articleServiceProvider),
    ref.watch(extractionJobProvider),
  ),
);

/// Téléchargement des images des chapitres, avant la fabrication du livre.
final imageDownloaderProvider = Provider<ImageDownloader>(
  (ref) => ImageDownloader(DioBinaryFetcher()),
);

final mailerProvider = Provider<KindleMailer>(
  (ref) => KindleMailer(
    images: ref.watch(imageDownloaderProvider),
    transport: ref.watch(mailTransportProvider),
    articles: ref.watch(articleServiceProvider),
    secrets: ref.watch(secretStoreProvider),
    settings: ref.watch(currentSettingsProvider),
    bookTitle: ref.watch(currentSettingsProvider).bookTitle,
  ),
);

/// Le transport réel. Les tests le remplacent par un faux ; l'application, lui,
/// ne l'instancie jamais tant qu'aucun envoi n'est demandé.
final mailTransportProvider = Provider<MailTransport>((ref) {
  final settings = ref.watch(currentSettingsProvider);
  return SmtpMailTransport(
    host: settings.smtpHost,
    port: settings.smtpPort,
    username: settings.smtpUsername,
    passwordProvider: () => ref.read(secretStoreProvider).readPassword(),
    useTls: settings.smtpUseTls,
  );
});

/// Étapes affichées pendant un envoi, pour que l'utilisateur sache où on en est.
enum SendStep { building, sending, done }

class SendState {
  const SendState({required this.step, this.outcome});

  final SendStep step;
  final SendOutcome? outcome;

  bool get isBusy => step != SendStep.done;
}

/// Lance l'envoi et tient l'état de la progression.
class SendController extends Notifier<SendState> {
  @override
  SendState build() => const SendState(step: SendStep.done);

  Future<void> send() async {
    state = const SendState(step: SendStep.building);

    final book = await ref.read(mailerProvider).buildBook();
    state = const SendState(step: SendStep.sending);

    final outcome = await ref.read(mailerProvider).send();
    state = SendState(step: SendStep.done, outcome: outcome);

    if (book.chapters.isNotEmpty) {
      ref.invalidate(sendQueueProvider);
    }
  }

  Future<void> sendTest() async {
    state = const SendState(step: SendStep.sending);
    final outcome = await ref.read(mailerProvider).sendTest();
    state = SendState(step: SendStep.done, outcome: outcome);
  }

  void reset() => state = const SendState(step: SendStep.done);
}

final sendControllerProvider = NotifierProvider<SendController, SendState>(
  SendController.new,
);
