import 'dart:convert';

import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:articles_kindle/data/settings.dart';
import 'package:articles_kindle/data/settings_backup_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemorySecretStore implements SecretStore {
  _InMemorySecretStore([this.password]);
  String? password;
  @override
  Future<void> writePassword(String value) async => password = value;
  @override
  Future<String?> readPassword() async => password;
  @override
  Future<void> deletePassword() async => password = null;
}

void main() {
  late AppDatabase db;
  late SettingsStore store;
  late _InMemorySecretStore secrets;
  late SettingsBackupService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = SettingsStore(db);
    secrets = _InMemorySecretStore('mon-mot-de-passe-secret');
    service = SettingsBackupService(store: store, secrets: secrets);
  });

  tearDown(() => db.close());

  group('SettingsBackupService', () {
    test(
      'exportJson inclut tous les réglages et le mot de passe secret',
      () async {
        await store.save(
          const AppSettings(
            kindleAddress: 'bison@kindle.com',
            smtpUsername: 'bison@gmail.com',
            smtpSender: 'bison@gmail.com',
            smtpHost: 'smtp.gmail.com',
            smtpPort: 587,
            smtpUseTls: true,
            downloadImages: true,
            grayscaleImages: true,
            imageMaxWidth: 800,
            sizeLimitMb: 25,
          ),
        );

        final jsonString = await service.exportJson();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        expect(data['version'], 1);
        final settings = data['settings'] as Map<String, dynamic>;
        expect(settings['kindleAddress'], 'bison@kindle.com');
        expect(settings['smtpUsername'], 'bison@gmail.com');

        final secretsMap = data['secrets'] as Map<String, dynamic>;
        expect(secretsMap['smtpPassword'], 'mon-mot-de-passe-secret');
      },
    );

    test(
      'importJson restaure correctement les réglages et le mot de passe',
      () async {
        const backupJson = '''
      {
        "version": 1,
        "settings": {
          "kindleAddress": "restaure@kindle.com",
          "smtpUsername": "restaure@gmail.com",
          "smtpHost": "smtp.mail.com",
          "smtpPort": 465,
          "smtpUseTls": true,
          "downloadImages": false
        },
        "secrets": {
          "smtpPassword": "nouveau-mot-de-passe"
        }
      }
      ''';

        await service.importJson(backupJson);

        final loaded = await store.load();
        expect(loaded.kindleAddress, 'restaure@kindle.com');
        expect(loaded.smtpUsername, 'restaure@gmail.com');
        expect(loaded.smtpHost, 'smtp.mail.com');
        expect(loaded.smtpPort, 465);
        expect(loaded.downloadImages, isFalse);

        expect(await secrets.readPassword(), 'nouveau-mot-de-passe');
      },
    );

    test('importJson rejette un JSON invalide avec FormatException', () async {
      expect(
        () => service.importJson('ceci n\'est pas du json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('importJson rejette une structure manquante', () async {
      expect(
        () => service.importJson('{"version": 1}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
