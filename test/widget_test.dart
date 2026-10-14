import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('quatre onglets, aucun onglet Flux', (tester) async {
    await pumpApp(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.tabToRead), findsWidgets);
    expect(find.text(l10n.tabSend), findsWidgets);
    expect(find.text(l10n.tabHistory), findsWidgets);
    expect(find.text(l10n.tabSettings), findsWidgets);
  });

  testWidgets('l\'écran À lire explique quand la liste est vide', (
    tester,
  ) async {
    await pumpApp(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.toReadEmptyTitle), findsOneWidget);
    expect(find.text(l10n.toReadEmptyBody), findsOneWidget);
  });

  testWidgets('un article ajouté apparaît dans la liste', (tester) async {
    final container = containerWithMemoryDatabase();
    await seedReadyArticle(
      container,
      'https://exemple.fr/a',
      title: 'Mon titre',
    );
    await pumpApp(tester, container: container);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text('Mon titre'), findsOneWidget);
    expect(find.text(l10n.toReadEmptyTitle), findsNothing);
  });

  testWidgets('le thème bascule et la barre suit', (tester) async {
    final container = containerWithMemoryDatabase();
    await pumpApp(tester, container: container);

    final context = tester.element(find.byType(NavigationBar));
    final theme = Theme.of(context);
    expect(theme.brightness, isNot(Brightness.dark));

    await tester.tap(find.byIcon(Icons.brightness_auto));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(NavigationBar))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(NavigationBar))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('la police de l\'interface est Libron', (tester) async {
    await pumpApp(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));
    final text = tester.widget<Text>(find.text(l10n.tabToRead).first);
    expect(
      text.style?.fontFamily ??
          Theme.of(tester.element(find.text(l10n.tabToRead).first))
              .textTheme
              .titleLarge
              ?.fontFamily,
      'Libron',
    );
  });
}
