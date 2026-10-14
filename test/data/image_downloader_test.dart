import 'dart:typed_data';

import 'package:articles_kindle/data/images/image_downloader.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _StubBinaryFetcher implements BinaryFetcher {
  _StubBinaryFetcher(this.bytes, {this.failing = false});

  final Uint8List bytes;
  final bool failing;
  final requested = <String>[];

  @override
  Future<Uint8List> get(String url) async {
    requested.add(url);
    if (failing) throw const NetworkUnavailable();
    return bytes;
  }
}

Uint8List jpegOf(int width, int height, {int gray = 0}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(gray, gray, gray));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  group('téléchargement', () {
    test('réduit une image trop large', () async {
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(jpegOf(2400, 1200))),
      );

      final image = await downloader.download(
        'https://exemple.fr/photo.jpg',
        index: 0,
        maxWidth: 800,
      );

      expect(image, isNotNull);
      final decoded = img.decodeImage(image!.bytes)!;
      expect(decoded.width, 800);
      expect(decoded.height, 400);
    });

    test('laisse une image déjà petite', () async {
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(jpegOf(320, 240))),
      );

      final image = await downloader.download(
        'https://exemple.fr/photo.jpg',
        index: 0,
        maxWidth: 800,
      );

      expect(img.decodeImage(image!.bytes)!.width, 320);
    });

    test('convertit en niveaux de gris', () async {
      final colored = img.Image(width: 10, height: 10);
      img.fill(colored, color: img.ColorRgb8(200, 30, 30));
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(img.encodeJpg(colored))),
      );

      final image = await downloader.download(
        'https://exemple.fr/photo.jpg',
        index: 0,
        grayscale: true,
      );

      final pixel = img.decodeImage(image!.bytes)!.getPixel(5, 5);
      // En niveaux de gris, les trois canaux sontnearly égaux.
      expect((pixel.r - pixel.g).abs(), lessThan(12));
      expect((pixel.g - pixel.b).abs(), lessThan(12));
    });

    test('garde la couleur si le réglage le demande', () async {
      final colored = img.Image(width: 10, height: 10);
      img.fill(colored, color: img.ColorRgb8(200, 30, 30));
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(img.encodeJpg(colored))),
      );

      final image = await downloader.download(
        'https://exemple.fr/photo.jpg',
        index: 0,
        grayscale: false,
      );

      final pixel = img.decodeImage(image!.bytes)!.getPixel(5, 5);
      expect(pixel.r, greaterThan(pixel.b + 50));
    });

    test(
      'une image injoignable est abandonnée sans faire échouer le chapitre',
      () async {
        final downloader = ImageDownloader(
          _StubBinaryFetcher(Uint8List(0), failing: true),
        );

        final image = await downloader.download(
          'https://exemple.fr/photo.jpg',
          index: 0,
        );

        expect(image, isNull);
      },
    );

    test('un contenu qui n\'est pas une image est abandonnée', () async {
      final notAnImage = Uint8List.fromList('ceci est du texte'.codeUnits);
      final downloader = ImageDownloader(_StubBinaryFetcher(notAnImage));

      final image = await downloader.download(
        'https://exemple.fr/photo.jpg',
        index: 0,
      );

      expect(image, isNull);
    });
  });

  group('intégration au chapitre', () {
    test('réécrit les src vers les fichiers locaux', () async {
      final downloader = ImageDownloader(_StubBinaryFetcher(jpegOf(1200, 800)));
      const html =
          '<p>Avant</p><img src="https://exemple.fr/photo.jpg" alt="Photo"/><p>Après</p>';

      final result = await downloader.process(html, chapterIndex: 1);

      expect(result.images, hasLength(1));
      expect(result.html, isNot(contains('https://exemple.fr/photo.jpg"')));
      expect(result.html, contains('../images/img-100.jpg'));
      expect(result.html, contains('<p>Avant</p>'));
      expect(result.html, contains('alt="Photo"'));
    });

    test('un chapitre sans image est renvoyé tel quel', () async {
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(jpegOf(10, 10))),
      );

      final result = await downloader.process(
        '<p>Que du texte</p>',
        chapterIndex: 0,
      );

      expect(result.images, isEmpty);
      expect(result.html, '<p>Que du texte</p>');
    });

    test('deux chapitres ne se volent pas leurs noms de fichier', () async {
      final downloader = ImageDownloader(
        _StubBinaryFetcher(Uint8List.fromList(jpegOf(10, 10))),
      );
      const html = '<img src="https://exemple.fr/photo.jpg"/>';

      final first = await downloader.process(html, chapterIndex: 0);
      final second = await downloader.process(html, chapterIndex: 1);

      expect(
        first.images.single.fileName,
        isNot(second.images.single.fileName),
      );
    });

    test('une image déjà locale n\'est pas téléchargée', () async {
      final fetcher = _StubBinaryFetcher(Uint8List.fromList(jpegOf(10, 10)));
      final downloader = ImageDownloader(fetcher);

      await downloader.process(
        '<img src="images/deja-la.jpg"/>',
        chapterIndex: 0,
      );

      expect(fetcher.requested, isEmpty);
    });
  });
}
