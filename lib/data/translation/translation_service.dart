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

class MyMemoryTranslationService implements TranslationService {
  MyMemoryTranslationService({
    required this.fetcher,
    this.maxChunkLength = 400,
  });

  final ArticleFetcher fetcher;
  final int maxChunkLength;

  static const String baseUrl = 'https://api.mymemory.translated.net/get';

  /// Découpe un texte en morceaux n'excédant pas [maxChunkLength], en coupant
  /// de préférence sur les espaces.
  List<String> chunkText(String text) {
    if (text.length <= maxChunkLength) return [text];

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
      queryParameters: {'q': chunk, 'langpair': '$sourceLang|$targetLang'},
    );

    try {
      final response = await fetcher.get(uri.toString());
      if (response.statusCode != 200) {
        return chunk;
      }

      final data = jsonDecode(response.body);
      if (data is Map && data['responseData'] is Map) {
        final translated = data['responseData']['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty) {
          return translated;
        }
      }
      return chunk;
    } catch (_) {
      // En cas d'erreur réseau, de quota ou de parse, on retombe toujours sur le texte original
      return chunk;
    }
  }

  @override
  Future<String> translateHtml(
    String html, {
    String sourceLang = 'en',
    String targetLang = 'fr',
  }) async {
    if (html.trim().isEmpty) return html;

    final fragment = html_parser.parseFragment(html);

    // Parcourir tous les nœuds de texte
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

    // Ignorer les balises pre et code pour ne pas altérer le code source
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
