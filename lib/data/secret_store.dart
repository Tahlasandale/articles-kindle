import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Coffre à secrets. Le mot de passe SMTP n'existe qu'ici et dans le Keystore :
/// jamais en base, jamais dans les journaux, jamais dans l'état de l'interface
/// plus d'une seconde.
abstract class SecretStore {
  Future<void> writePassword(String password);
  Future<String?> readPassword();
  Future<void> deletePassword();
}

class SecureStorageSecretStore implements SecretStore {
  /// Le Keystore Android est utilisé par défaut ; c'est lui qui protège la clé.
  SecureStorageSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _passwordKey = 'smtp_password';

  final FlutterSecureStorage _storage;

  @override
  Future<void> writePassword(String password) =>
      _storage.write(key: _passwordKey, value: password);

  @override
  Future<String?> readPassword() => _storage.read(key: _passwordKey);

  @override
  Future<void> deletePassword() => _storage.delete(key: _passwordKey);
}

final secretStoreProvider = Provider<SecretStore>(
  (ref) => SecureStorageSecretStore(),
);
