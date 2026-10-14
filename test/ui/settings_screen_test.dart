import 'package:articles_kindle/data/mail/mail_transport.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:articles_kindle/data/settings.dart';
import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

class _FakeSuccessfulTransport implements MailTransport {
  @override
  Future<void> send(OutgoingMessage message) async {}
}

class _InMemorySecretStore implements SecretStore {
  _InMemorySecretStore([this.password = 'mot-de-passe-application']);
  String? password;
  @override
  Future<void> writePassword(String value) async => password = value;
  @override
  Future<String?> readPassword() async => password;
  @override
  Future<void> deletePassword() async => password = null;
}

void main() {
  testWidgets(
    'affiche le bouton de test SMTP dans les réglages et affiche un message de succès',
    (tester) async {
      final secrets = _InMemorySecretStore('app-password');
      final container = containerWithMemoryDatabase(
        overrides: [
          secretStoreProvider.overrideWithValue(secrets),
          mailTransportProvider.overrideWithValue(_FakeSuccessfulTransport()),
        ],
      );

      // Initialiser les réglages avec une adresse kindle et smtp
      await container
          .read(settingsStoreProvider)
          .save(
            const AppSettings(
              kindleAddress: 'moi@kindle.com',
              smtpUsername: 'user@gmail.com',
            ),
          );
      container.invalidate(settingsProvider);

      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: Locale('fr'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final testButton = find.text(l10n.sendTestButton);
      await tester.scrollUntilVisible(
        testButton,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(testButton, findsOneWidget);

      await tester.tap(testButton);
      await tester.pumpAndSettle();

      expect(find.text(l10n.sendTestSuccess), findsOneWidget);
    },
  );

  testWidgets('affiche les liens d aide vers Amazon et Google', (tester) async {
    final container = containerWithMemoryDatabase();
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: Locale('fr'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsKindleLink), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.settingsGoogleLink),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.settingsGoogleLink), findsOneWidget);
  });

  testWidgets('permet de basculer facilement entre le port 465 et 587', (
    tester,
  ) async {
    final container = containerWithMemoryDatabase();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: Locale('fr'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chip465 = find.text('Port 465 (SSL / 4G-5G)');
    await tester.scrollUntilVisible(
      chip465,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(chip465, findsOneWidget);

    await tester.tap(chip465);
    await tester.pumpAndSettle();

    expect(container.read(currentSettingsProvider).smtpPort, 465);
  });
}
