import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/ingest.dart';
import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/ui/router.dart';
import 'package:articles_kindle/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticlesKindleApp extends ConsumerStatefulWidget {
  const ArticlesKindleApp({super.key});

  @override
  ConsumerState<ArticlesKindleApp> createState() => _ArticlesKindleAppState();
}

class _ArticlesKindleAppState extends ConsumerState<ArticlesKindleApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenToShares());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// L'application peut être ouverte par le menu Partager alors qu'elle était
  /// fermée : l'écoute doit repartir à chaque retour au premier plan.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _listenToShares();
  }

  void _listenToShares() {
    ref.read(shareReceiverProvider).start(_ingestShared);
  }

  Future<void> _ingestShared(List<String> urls) async {
    for (final url in urls) {
      final outcome = await ref
          .read(ingestProvider)
          .addAndExtract(url, origin: ArticleOrigin.share);
      if (!mounted) return;
      _announce(outcome);
    }
  }

  /// Feuille très courte : l'utilisateur doit pouvoir repartir immédiatement
  /// vers l'application d'origine.
  void _announce(IngestOutcome outcome) {
    final l10n = L10n.of(context);
    if (l10n == null) return;

    final message = switch (outcome) {
      IngestOutcome(isDuplicate: true) => l10n.addUrlDuplicate,
      IngestOutcome(isReady: true) => l10n.statusReady,
      IngestOutcome(status: ArticleStatus.failed) =>
        outcome.reason ?? l10n.statusFailed,
      _ => l10n.addUrlInvalid,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(currentSettingsProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => L10n.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: Eink.themeFor(Brightness.light),
      darkTheme: Eink.themeFor(Brightness.dark),
      themeMode: settings.themeMode,
      locale: const Locale('fr'),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
