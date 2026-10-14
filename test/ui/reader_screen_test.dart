import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/ui/screens/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late FakeWebViewPlatform fakePlatform;

  setUp(() {
    fakePlatform = initFakeWebView();
  });

  testWidgets(
    "ReaderScreen affiche le titre et charge le contenu HTML stylisé",
    (tester) async {
      final container = containerWithMemoryDatabase();
      final article = await seedReadyArticle(
        container,
        'https://example.com/test-article',
        title: 'Mon bel article',
        contentHtml: '<p>Contenu fascinant</p>',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: ReaderScreen(articleId: article.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mon bel article'), findsOneWidget);
      expect(fakePlatform.lastController, isNotNull);
      final loaded = fakePlatform.lastController!.loadedHtml;
      expect(loaded, isNotNull);
      expect(loaded, contains('Contenu fascinant'));
      expect(loaded, contains('font-family'));
    },
  );

  testWidgets("ReaderScreen affiche un message d'absence de contenu si vide", (
    tester,
  ) async {
    final container = containerWithMemoryDatabase();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: ReaderScreen(articleId: 9999),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(
      find.text('Aucun contenu disponible pour la lecture hors-ligne.'),
      findsOneWidget,
    );
  });

  testWidgets("ToReadScreen propose un bouton Lire vers l'article", (
    tester,
  ) async {
    final container = containerWithMemoryDatabase();
    await seedReadyArticle(
      container,
      'https://example.com/art1',
      title: 'Article à lire',
      contentHtml: '<p>Contenu prêt</p>',
    );

    await pumpApp(tester, container: container);
    await tester.pumpAndSettle();

    final readButton = find.widgetWithText(OutlinedButton, 'Lire');
    expect(readButton, findsOneWidget);

    await tester.tap(readButton);
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('Article à lire'), findsOneWidget);
  });

  testWidgets(
    "HistoryScreen propose un bouton Lire pour les articles envoyés",
    (tester) async {
      final container = containerWithMemoryDatabase();
      final article = await seedReadyArticle(
        container,
        'https://example.com/art-sent',
        title: 'Article déjà envoyé',
        contentHtml: '<p>Contenu archivé</p>',
      );

      // Marquer l'article comme envoyé
      await container.read(articleServiceProvider).markSent([article.id]);

      await pumpApp(tester, container: container);
      await tester.pumpAndSettle();

      // Naviguer vers l'onglet Historique (index 2)
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      final readButton = find.widgetWithText(OutlinedButton, 'Lire');
      expect(readButton, findsOneWidget);

      await tester.tap(readButton);
      await tester.pumpAndSettle();

      expect(find.byType(ReaderScreen), findsOneWidget);
      expect(find.text('Article déjà envoyé'), findsOneWidget);
    },
  );

  testWidgets("ReaderScreen affiche le bouton de retraduction", (tester) async {
    final container = containerWithMemoryDatabase();
    final article = await seedReadyArticle(
      container,
      'https://example.com/art-translate',
      title: 'Article à retraduire',
      contentHtml: '<p>Contenu initial</p>',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: ReaderScreen(articleId: article.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final retranslateIcon = find.byIcon(Icons.translate);
    expect(retranslateIcon, findsOneWidget);
  });
}
