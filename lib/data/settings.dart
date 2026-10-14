import 'package:articles_kindle/data/db/database.dart';
import 'package:flutter/material.dart';

/// Réglages de l'application. Le mot de passe SMTP n'est pas ici : il vit dans
/// le Keystore et n'est jamais écrit en base (voir `SecretStore`).
class AppSettings {
  const AppSettings({
    this.kindleAddress = '',
    this.bookTitle = '',
    this.smtpHost = 'smtp.gmail.com',
    this.smtpPort = 587,
    this.smtpUseTls = true,
    this.smtpUsername = '',
    this.smtpSender = '',
    this.downloadImages = true,
    this.grayscaleImages = true,
    this.imageMaxWidth = 800,
    this.sizeLimitMb = 25,
    this.translateToFrench = false,
    this.themeMode = ThemeMode.system,
  });

  final String kindleAddress;
  final String bookTitle;
  final String smtpHost;
  final int smtpPort;
  final bool smtpUseTls;
  final String smtpUsername;
  final String smtpSender;
  final bool downloadImages;
  final bool grayscaleImages;
  final int imageMaxWidth;
  final int sizeLimitMb;
  final bool translateToFrench;
  final ThemeMode themeMode;

  bool get isSmtpConfigured =>
      kindleAddress.contains('@') && smtpUsername.isNotEmpty;

  AppSettings copyWith({
    String? kindleAddress,
    String? bookTitle,
    String? smtpHost,
    int? smtpPort,
    bool? smtpUseTls,
    String? smtpUsername,
    String? smtpSender,
    bool? downloadImages,
    bool? grayscaleImages,
    int? imageMaxWidth,
    int? sizeLimitMb,
    bool? translateToFrench,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      kindleAddress: kindleAddress ?? this.kindleAddress,
      bookTitle: bookTitle ?? this.bookTitle,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpUseTls: smtpUseTls ?? this.smtpUseTls,
      smtpUsername: smtpUsername ?? this.smtpUsername,
      smtpSender: smtpSender ?? this.smtpSender,
      downloadImages: downloadImages ?? this.downloadImages,
      grayscaleImages: grayscaleImages ?? this.grayscaleImages,
      imageMaxWidth: imageMaxWidth ?? this.imageMaxWidth,
      sizeLimitMb: sizeLimitMb ?? this.sizeLimitMb,
      translateToFrench: translateToFrench ?? this.translateToFrench,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, String> toMap() => {
    'kindleAddress': kindleAddress,
    'bookTitle': bookTitle,
    'smtpHost': smtpHost,
    'smtpPort': '$smtpPort',
    'smtpUseTls': '$smtpUseTls',
    'smtpUsername': smtpUsername,
    'smtpSender': smtpSender,
    'downloadImages': '$downloadImages',
    'grayscaleImages': '$grayscaleImages',
    'imageMaxWidth': '$imageMaxWidth',
    'sizeLimitMb': '$sizeLimitMb',
    'translateToFrench': '$translateToFrench',
    'themeMode': themeMode.name,
  };

  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      kindleAddress: map['kindleAddress'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      smtpHost: map['smtpHost'] ?? 'smtp.gmail.com',
      smtpPort: int.tryParse(map['smtpPort'] ?? '') ?? 587,
      smtpUseTls: map['smtpUseTls'] != 'false',
      smtpUsername: map['smtpUsername'] ?? '',
      smtpSender: map['smtpSender'] ?? '',
      downloadImages: map['downloadImages'] != 'false',
      grayscaleImages: map['grayscaleImages'] != 'false',
      imageMaxWidth: int.tryParse(map['imageMaxWidth'] ?? '') ?? 800,
      sizeLimitMb: int.tryParse(map['sizeLimitMb'] ?? '') ?? 25,
      translateToFrench: map['translateToFrench'] == 'true',
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == map['themeMode'],
        orElse: () => ThemeMode.system,
      ),
    );
  }
}

/// Lecture et écriture des réglages dans la table `settings`.
class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  Future<AppSettings> load() async {
    final rows = await _db.select(_db.settings).get();
    return AppSettings.fromMap({for (final row in rows) row.key: row.value});
  }

  Future<void> save(AppSettings settings) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.settings, [
        for (final entry in settings.toMap().entries)
          SettingsCompanion.insert(key: entry.key, value: entry.value),
      ]);
    });
  }
}
