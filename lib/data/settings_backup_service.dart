import 'dart:convert';

import 'package:flutter/material.dart';

import 'secret_store.dart';
import 'settings.dart';

/// Service d'exportation et d'importation des réglages et secrets de l'application.
///
/// Permet de sauvegarder ou restaurer la configuration (y compris les identifiants)
/// pour faciliter les tests ou le passage d'un appareil à l'autre.
class SettingsBackupService {
  const SettingsBackupService({required this.store, required this.secrets});

  final SettingsStore store;
  final SecretStore secrets;

  /// Exporte les réglages et le mot de passe actuel sous forme de chaîne JSON.
  Future<String> exportJson() async {
    final settings = await store.load();
    final password = await secrets.readPassword() ?? '';

    final payload = {
      'version': 1,
      'settings': {
        'kindleAddress': settings.kindleAddress,
        'bookTitle': settings.bookTitle,
        'smtpHost': settings.smtpHost,
        'smtpPort': settings.smtpPort,
        'smtpUseTls': settings.smtpUseTls,
        'smtpUsername': settings.smtpUsername,
        'smtpSender': settings.smtpSender,
        'downloadImages': settings.downloadImages,
        'grayscaleImages': settings.grayscaleImages,
        'imageMaxWidth': settings.imageMaxWidth,
        'sizeLimitMb': settings.sizeLimitMb,
        'themeMode': settings.themeMode.name,
      },
      'secrets': {'smtpPassword': password},
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Importe une chaîne JSON et applique les réglages et secrets.
  Future<void> importJson(String jsonString) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('JSON invalide : $e');
    }

    if (decoded is! Map<String, dynamic> || !decoded.containsKey('settings')) {
      throw const FormatException(
        'Structure de sauvegarde invalide (clé "settings" manquante).',
      );
    }

    final settingsMap = decoded['settings'];
    if (settingsMap is! Map) {
      throw const FormatException(
        'Le contenu de "settings" n\'est pas un objet JSON valide.',
      );
    }

    // Charger les réglages actuels pour servir de base
    final current = await store.load();

    final next = current.copyWith(
      kindleAddress:
          settingsMap['kindleAddress']?.toString() ?? current.kindleAddress,
      bookTitle: settingsMap['bookTitle']?.toString() ?? current.bookTitle,
      smtpHost: settingsMap['smtpHost']?.toString() ?? current.smtpHost,
      smtpPort: settingsMap['smtpPort'] is int
          ? settingsMap['smtpPort'] as int
          : int.tryParse(settingsMap['smtpPort']?.toString() ?? '') ??
                current.smtpPort,
      smtpUseTls: settingsMap['smtpUseTls'] is bool
          ? settingsMap['smtpUseTls'] as bool
          : current.smtpUseTls,
      smtpUsername:
          settingsMap['smtpUsername']?.toString() ?? current.smtpUsername,
      smtpSender: settingsMap['smtpSender']?.toString() ?? current.smtpSender,
      downloadImages: settingsMap['downloadImages'] is bool
          ? settingsMap['downloadImages'] as bool
          : current.downloadImages,
      grayscaleImages: settingsMap['grayscaleImages'] is bool
          ? settingsMap['grayscaleImages'] as bool
          : current.grayscaleImages,
      imageMaxWidth: settingsMap['imageMaxWidth'] is int
          ? settingsMap['imageMaxWidth'] as int
          : int.tryParse(settingsMap['imageMaxWidth']?.toString() ?? '') ??
                current.imageMaxWidth,
      sizeLimitMb: settingsMap['sizeLimitMb'] is int
          ? settingsMap['sizeLimitMb'] as int
          : int.tryParse(settingsMap['sizeLimitMb']?.toString() ?? '') ??
                current.sizeLimitMb,
      themeMode: settingsMap['themeMode'] != null
          ? ThemeMode.values.firstWhere(
              (m) => m.name == settingsMap['themeMode'],
              orElse: () => current.themeMode,
            )
          : current.themeMode,
    );

    await store.save(next);

    final secretsMap = decoded['secrets'];
    if (secretsMap is Map && secretsMap.containsKey('smtpPassword')) {
      final pwd = secretsMap['smtpPassword']?.toString() ?? '';
      await secrets.writePassword(pwd);
    }
  }
}
