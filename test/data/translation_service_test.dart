import 'dart:convert';

import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:articles_kindle/data/translation/translation_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubFetcher implements ArticleFetcher {
  _StubFetcher(this.responses);

  final Map<String, dynamic> responses;
  final requestedUrls = <String>[];

  @override
  Future<FetchedPage> get(String url) async {
    requestedUrls.add(url);
    for (final entry in responses.entries) {
      if (url.contains(entry.key)) {
        return FetchedPage(
          url: url,
          statusCode: 200,
          body: jsonEncode(entry.value),
        );
      }
    }
    return FetchedPage(
      url: url,
      statusCode: 404,
      body: '{"responseStatus": 404, "responseData": {"translatedText": ""}}',
    );
  }
}

void main() {
  group('MyMemoryTranslationService', () {
    test(
      'traduit un texte simple anglais vers français via MyMemory',
      () async {
        final fetcher = _StubFetcher({
          'Hello+world': {
            'responseData': {
              'translatedText': 'Bonjour le monde',
              'match': 0.95,
            },
            'responseStatus': 200,
          },
        });

        final service = MyMemoryTranslationService(fetcher: fetcher);
        final translated = await service.translateText('Hello world');

        expect(translated, 'Bonjour le monde');
        expect(fetcher.requestedUrls.length, 1);
        expect(fetcher.requestedUrls.first, contains('langpair=en%7Cfr'));
      },
    );

    test('inclut le paramètre de= si un e-mail est fourni', () async {
      final fetcher = _StubFetcher({
        'Hello': {
          'responseData': {'translatedText': 'Bonjour'},
          'responseStatus': 200,
        },
      });

      final service = MyMemoryTranslationService(
        fetcher: fetcher,
        email: 'user@example.com',
      );
      await service.translateText('Hello');

      expect(fetcher.requestedUrls.first, contains('de=user%40example.com'));
    });

    test('ignore un avertissement de quota MYMEMORY WARNING et retombe sur original', () async {
      final fetcher = _StubFetcher({
        'Hello': {
          'responseData': {
            'translatedText':
                'MYMEMORY WARNING: YOU USED ALL AVAILABLE FREE TRANSLATIONS...',
          },
          'responseStatus': 429,
        },
      });

      final service = MyMemoryTranslationService(fetcher: fetcher);
      final result = await service.translateText('Hello');
      expect(result, 'Hello');
    });

    test('traduit un fragment HTML en conservant la structure des balises', () async {
      final fetcher = _StubFetcher({
        'First+title': {
          'responseData': {'translatedText': 'Premier titre'},
          'responseStatus': 200,
        },
        'A+paragraph+with': {
          'responseData': {'translatedText': 'Un paragraphe avec'},
          'responseStatus': 200,
        },
        'bold': {
          'responseData': {'translatedText': 'gras'},
          'responseStatus': 200,
        },
        'text.': {
          'responseData': {'translatedText': 'texte.'},
          'responseStatus': 200,
        },
      });

      final service = MyMemoryTranslationService(fetcher: fetcher);
      const html =
          '<h2>First title</h2><p>A paragraph with <strong>bold</strong> text.</p>';
      final translated = await service.translateHtml(html);

      expect(translated, contains('<h2>Premier titre</h2>'));
      expect(translated, contains('<strong>gras</strong>'));
      expect(translated, contains('Un paragraphe avec'));
    });

    test('retombe sur le texte original si le réseau échoue', () async {
      final fetcher = _StubFetcher({}); // Tout échoue en 404
      final service = MyMemoryTranslationService(fetcher: fetcher);

      final result = await service.translateText('Resilient text');
      expect(result, 'Resilient text');
    });

    test(
      'découpe les textes longs en tronçons pour respecter la limite d\'URL',
      () async {
        final fetcher = _StubFetcher({
          'segment': {
            'responseData': {'translatedText': 'tronçon'},
            'responseStatus': 200,
          },
        });

        final service = MyMemoryTranslationService(
          fetcher: fetcher,
          maxChunkLength: 30,
        );
        final chunks = service.chunkText(
          'This is a longer sentence that should definitely be split into pieces.',
        );

        expect(chunks.length, greaterThan(1));
        for (final chunk in chunks) {
          expect(chunk.length, lessThanOrEqualTo(40));
        }
      },
    );
  });

  group('GoogleGtxTranslationService', () {
    test(
      'traduit un texte en parsant la réponse hiérarchique Google Translate',
      () async {
        final fetcher = _StubFetcher({
          'client=gtx': [
            [
              ['Bonjour le monde', 'Hello world', null, null, 10],
            ],
            null,
            'en',
          ],
        });

        final service = GoogleGtxTranslationService(fetcher: fetcher);
        final translated = await service.translateText('Hello world');

        expect(translated, 'Bonjour le monde');
        expect(fetcher.requestedUrls.first, contains('client=gtx'));
      },
    );
  });

  group('CompositeTranslationService', () {
    test('utilise le second service si le premier échoue', () async {
      // Premier service échoue (renvoie original)
      final failingFetcher = _StubFetcher({});
      final primary = MyMemoryTranslationService(fetcher: failingFetcher);

      // Second service réussit
      final succeedingFetcher = _StubFetcher({
        'client=gtx': [
          [
            ['Bonjour secouru', 'Hello rescued', null, null, 10],
          ],
        ],
      });
      final fallback = GoogleGtxTranslationService(fetcher: succeedingFetcher);

      final composite = CompositeTranslationService(
        services: [primary, fallback],
      );

      final translated = await composite.translateText('Hello rescued');
      expect(translated, 'Bonjour secouru');
    });
  });
}
