import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Réception du menu Partager d'Android.
///
/// Le partage est une entrée comme une autre : on en tire des adresses web, et
/// l'appelant décide quoi en faire. Le plugin n'est isolé que dans ce fichier,
/// pour que le reste de l'application — et ses tests — n'aient rien à voir avec
/// les intents Android.
class ShareReceiver {
  /// L'interface minimale dont on a besoin, pour que les tests n'aient pas à
  ///Talking au plugin.
  ShareReceiver([ReceiveSharingIntent? plugin])
    : _plugin = plugin ?? ReceiveSharingIntent.instance;

  final ReceiveSharingIntent _plugin;

  StreamSubscription<List<SharedMediaFile>>? _subscription;

  /// Démarre l'écoute et rend les adresses reçues. L'intent qui a lancé
  /// l'application est traité immédiatement, les suivants au fil de l'eau.
  Future<void> start(void Function(List<String> urls) onUrls) async {
    final initial = await _plugin.getInitialMedia();
    final first = urlsOf(initial);
    if (first.isNotEmpty) onUrls(first);
    // Sans cet appel, Android rejoue le même partage au prochain lancement.
    if (initial.isNotEmpty) await _plugin.reset();

    _subscription = _plugin.getMediaStream().listen((files) {
      final urls = urlsOf(files);
      if (urls.isNotEmpty) onUrls(urls);
    }, onError: (Object error) => debugPrint('Partage illisible : $error'));
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Les adresses web contenues dans ce qui a été partagé.
  ///
  /// Android envoie un partage de texte comme un fichier `text/plain` dont le
  /// contenu est dans `path` ; certains navigateurs envoient directement
  /// l'adresse comme type `url`.
  static List<String> urlsOf(List<SharedMediaFile> files) {
    final urls = <String>[];

    for (final file in files) {
      final candidate = file.type == SharedMediaType.url
          ? file.path
          : (file.type == SharedMediaType.text ? file.path : null);
      if (candidate == null) continue;

      for (final url in extractUrls(candidate)) {
        if (!urls.contains(url)) urls.add(url);
      }
    }

    return urls;
  }

  static final RegExp _urlPattern = RegExp(
    r'https?://[^\s<>"»\]]+',
    caseSensitive: false,
  );

  /// Les adresses contenues dans un texte partagé : « Regarde ça :
  /// https://exemple.fr/a », c'est l'adresse qui compte, pas la phrase.
  static List<String> extractUrls(String text) {
    final seen = <String>{};
    final urls = <String>[];

    for (final match in _urlPattern.allMatches(text)) {
      // Un navigateur colle parfois une virgule ou un point à la fin.
      final url = match
          .group(0)!
          .trim()
          .replaceAll(RegExp(r'[.,;:!?)\]»]+$'), '');
      if (url.length <= 'https://'.length) continue;
      if (seen.add(url)) urls.add(url);
    }
    return urls;
  }
}
