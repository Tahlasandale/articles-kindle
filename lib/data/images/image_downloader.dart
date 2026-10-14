import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:articles_kindle/data/epub/epub_builder.dart';
import 'package:image/image.dart' as img;

/// Téléchargement binaire. Séparé de [ArticleFetcher] parce qu'une image n'est pas
/// une page : elle ne se parse pas, elle se redimensionne.
abstract class BinaryFetcher {
  Future<Uint8List> get(String url);
}

class DioBinaryFetcher implements BinaryFetcher {
  DioBinaryFetcher({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Une image de couverture outweigh dix pages de texte : au-delà, on renonce
  /// plutôt que d'attendre.
  static const int maxBytes = 4 * 1024 * 1024;

  @override
  Future<Uint8List> get(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        maxRedirects: 5,
        headers: const {'User-Agent': DioArticleFetcher.userAgent},
        receiveTimeout: DioArticleFetcher.timeout,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final bytes = response.data ?? const <int>[];
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const FetchTooLarge();
    }
    return Uint8List.fromList(bytes);
  }
}

/// Transforme les images d'un chapitre en fichiers d'EPUB : largeur bornée,
/// niveaux de gris, JPEG.
///
/// Une image qui ne peut pas être téléchargée ou décodée ne fait pas échouer
/// l'article : elle est simplement absente du livre.
class ImageDownloader {
  ImageDownloader(this._fetcher);

  final BinaryFetcher _fetcher;

  /// Renvoie l'image prête pour l'EPUB, ou `null` si elle est inutilisable.
  Future<EpubImage?> download(
    String url, {
    required int index,
    int maxWidth = 800,
    bool grayscale = true,
  }) async {
    final Uint8List bytes;
    try {
      bytes = await _fetcher.get(url);
    } catch (_) {
      return null;
    }

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    var image = decoded;
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }
    if (grayscale) {
      image = img.grayscale(image);
    }

    final encoded = Uint8List.fromList(img.encodeJpg(image, quality: 80));
    return EpubImage(
      fileName: 'img-${index.toString().padLeft(3, '0')}.jpg',
      bytes: encoded,
      mimeType: 'image/jpeg',
    );
  }

  /// Télécharge toutes les images d'un chapitre et réécrit les `src` pour pointer
  /// vers les fichiers locaux. Renvoie le HTML nettoyé et les images à embarquer.
  Future<({String html, List<EpubImage> images})> process(
    String contentHtml, {
    required int chapterIndex,
    int maxWidth = 800,
    bool grayscale = true,
  }) async {
    final urls = <String>[];
    final pattern = RegExp(r'<img[^>]*src="([^"]+)"[^>]*>');
    for (final match in pattern.allMatches(contentHtml)) {
      final url = match.group(1);
      if (url != null && url.startsWith('http') && !urls.contains(url)) {
        urls.add(url);
      }
    }

    if (urls.isEmpty) {
      return (html: contentHtml, images: const <EpubImage>[]);
    }

    final images = <EpubImage>[];
    var html = contentHtml;
    for (var i = 0; i < urls.length; i++) {
      final image = await download(
        urls[i],
        index: chapterIndex * 100 + i,
        maxWidth: maxWidth,
        grayscale: grayscale,
      );
      if (image == null) continue;

      images.add(image);
      html = html.replaceAll('"${urls[i]}"', '"../images/${image.fileName}"');
    }

    return (html: html, images: images);
  }
}
