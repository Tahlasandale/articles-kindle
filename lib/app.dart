import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/ui/router.dart';
import 'package:articles_kindle/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticlesKindleApp extends ConsumerWidget {
  const ArticlesKindleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
