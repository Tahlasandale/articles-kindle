import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../net/article_fetcher.dart';

abstract class TranslationService {
  Future<String> translateText(
    String text, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  });

  Future<String> translateHtml(
    String html, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  });
}

/// Classe de base fournissant le découpage et le parcours HTML commun.
abstract class BaseTranslationService implements TranslationService {
  int get maxChunkLength => 400;

  /// Découpe un texte en morceaux n'excédant pas [maxChunkLength], en coupant
  /// de préférence sur les ponctuations de fin de phrase puis sur les espaces.
  List<String> chunkText(String text) {
    if (text.length <= maxChunkLength) return [text];

    final chunks = <String>[];
    // Découper d'abord en phrases potentielles
    final sentences = _splitSentences(text);
    var current = StringBuffer();

    for (final sentence in sentences) {
      if (sentence.length > maxChunkLength) {
        // La phrase seule est plus longue que la limite, on la découpe par mots
        if (current.isNotEmpty) {
          chunks.add(current.toString().trim());
          current = StringBuffer();
        }
        final wordChunks = _splitByWords(sentence);
        chunks.addAll(wordChunks);
      } else if (current.length + sentence.length + 1 > maxChunkLength) {
        if (current.isNotEmpty) {
          chunks.add(current.toString().trim());
          current = StringBuffer();
        }
        current.write(sentence);
      } else {
        if (current.isNotEmpty) current.write(' ');
        current.write(sentence);
      }
    }
    if (current.isNotEmpty) {
      chunks.add(current.toString().trim());
    }
    return chunks;
  }

  List<String> _splitSentences(String text) {
    final result = <String>[];
    final regex = RegExp(r'([^.!?\n]+[.!?\n]*)');
    for (final match in regex.allMatches(text)) {
      final part = match.group(0)?.trim();
      if (part != null && part.isNotEmpty) {
        result.add(part);
      }
    }
    return result.isEmpty ? [text] : result;
  }

  List<String> _splitByWords(String text) {
    final chunks = <String>[];
    final words = text.split(' ');
    var current = StringBuffer();

    for (final word in words) {
      if (current.length + word.length + 1 > maxChunkLength &&
          current.isNotEmpty) {
        chunks.add(current.toString().trim());
        current = StringBuffer();
      }
      if (current.isNotEmpty) current.write(' ');
      current.write(word);
    }
    if (current.isNotEmpty) {
      chunks.add(current.toString().trim());
    }
    return chunks;
  }

  @override
  Future<String> translateHtml(
    String html, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  }) async {
    if (html.trim().isEmpty) return html;

    final fragment = html_parser.parseFragment(html);

    await _translateNode(
      fragment,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    final result = StringBuffer();
    for (final node in fragment.nodes) {
      if (node is dom.Element) {
        result.write(node.outerHtml);
      } else if (node is dom.Text) {
        result.write(node.text);
      }
    }
    return result.toString();
  }

  Future<void> _translateNode(
    dom.Node node, {
    required String sourceLang,
    required String targetLang,
  }) async {
    if (node is dom.Text) {
      final text = node.text;
      if (text.trim().isNotEmpty) {
        final translated = await translateText(
          text.trim(),
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
        final leading = text.startsWith(RegExp(r'\s')) ? ' ' : '';
        final trailing = RegExp(r'\s$').hasMatch(text) ? ' ' : '';
        node.text = '$leading$translated$trailing';
      }
      return;
    }

    if (node is dom.Element &&
        (node.localName == 'pre' || node.localName == 'code')) {
      return;
    }

    for (final child in node.nodes) {
      await _translateNode(
        child,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    }
  }
}

/// Moteur MyMemory avec support du paramètre email `&de=` et détection de quota.
class MyMemoryTranslationService extends BaseTranslationService {
  MyMemoryTranslationService({
    required this.fetcher,
    this.email,
    this.maxChunkLength = 400,
  });

  final ArticleFetcher fetcher;
  final String? email;
  @override
  final int maxChunkLength;

  static const String baseUrl = 'https://api.mymemory.translated.net/get';

  @override
  Future<String> translateText(
    String text, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final chunks = chunkText(trimmed);
    final translatedChunks = <String>[];

    for (final chunk in chunks) {
      final translated = await _translateSingleChunk(
        chunk,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      translatedChunks.add(translated);
    }

    return translatedChunks.join(' ');
  }

  Future<String> _translateSingleChunk(
    String chunk, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final queryParams = <String, String>{
      'q': chunk,
      'langpair': '$sourceLang|$targetLang',
      if (email != null && email!.trim().contains('@')) 'de': email!.trim(),
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await fetcher.get(uri.toString());
      if (response.statusCode != 200) {
        return chunk;
      }

      final data = jsonDecode(response.body);
      if (data is Map) {
        final status = data['responseStatus'];
        if (status != 200 && status != '200') {
          return chunk;
        }

        if (data['responseData'] is Map) {
          final translated = data['responseData']['translatedText'] as String?;
          if (translated != null &&
              translated.isNotEmpty &&
              !translated.toUpperCase().contains('MYMEMORY WARNING')) {
            return translated;
          }
        }
      }
      return chunk;
    } catch (_) {
      return chunk;
    }
  }
}

/// Moteur de traduction Google GTX (Web API gratuite, sans limite de quota journalier).
class GoogleGtxTranslationService extends BaseTranslationService {
  GoogleGtxTranslationService({
    required this.fetcher,
    this.maxChunkLength = 1000,
  });

  final ArticleFetcher fetcher;
  @override
  final int maxChunkLength;

  static const String baseUrl =
      'https://translate.googleapis.com/translate_a/single';

  @override
  Future<String> translateText(
    String text, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final chunks = chunkText(trimmed);
    final translatedChunks = <String>[];

    for (final chunk in chunks) {
      final translated = await _translateSingleChunk(
        chunk,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      translatedChunks.add(translated);
    }

    return translatedChunks.join(' ');
  }

  Future<String> _translateSingleChunk(
    String chunk, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'client': 'gtx',
        'sl': sourceLang,
        'tl': targetLang,
        'dt': 't',
        'q': chunk,
      },
    );

    try {
      final response = await fetcher.get(uri.toString());
      if (response.statusCode != 200) {
        return chunk;
      }

      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty && data[0] is List) {
        final buffer = StringBuffer();
        for (final segment in data[0]) {
          if (segment is List && segment.isNotEmpty && segment[0] is String) {
            buffer.write(segment[0]);
          }
        }
        final result = buffer.toString();
        if (result.isNotEmpty) {
          return result;
        }
      }
      return chunk;
    } catch (_) {
      return chunk;
    }
  }
}

/// Moteur composite essayant les services successivement (fallback transparent).
class CompositeTranslationService extends BaseTranslationService {
  CompositeTranslationService({required this.services});

  final List<TranslationService> services;

  @override
  Future<String> translateText(
    String text, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    for (final service in services) {
      try {
        final result = await service.translateText(
          text,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
        // Si le service a renvoyé un texte différent, la traduction a réussi
        if (result.trim() != trimmed) {
          return result;
        }
      } catch (_) {
        // En cas d'exception, on passe au service suivant
        continue;
      }
    }

    return text;
  }
}
