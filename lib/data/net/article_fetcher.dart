import 'package:dio/dio.dart';

/// Ce qu'une page téléchargée donne à l'extracteur.
class FetchedPage {
  const FetchedPage({
    required this.url,
    required this.body,
    this.statusCode = 200,
    this.contentType,
  });

  final String url;
  final String body;
  final int statusCode;
  final String? contentType;
}

/// Tout ce qui peut empêcher une page d'arriver. Chaque cas a son message : un
/// « échec » nu ne dit pas à l'utilisateur s'il doit réessayer ou changer d'article.
sealed class FetchFailure implements Exception {
  const FetchFailure();

  String get message;
}

class NetworkUnavailable extends FetchFailure {
  const NetworkUnavailable();
  @override
  String get message => 'Pas de connexion.';
}

class FetchTimedOut extends FetchFailure {
  const FetchTimedOut();
  @override
  String get message => 'Le site n\'a pas répondu à temps.';
}

class FetchStatusError extends FetchFailure {
  const FetchStatusError(this.statusCode);
  final int statusCode;
  @override
  String get message => 'Le site a répondu $statusCode.';
}

class FetchTooLarge extends FetchFailure {
  const FetchTooLarge();
  @override
  String get message => 'Cette page est trop lourde pour être téléchargée.';
}

class FetchUnsupportedScheme extends FetchFailure {
  const FetchUnsupportedScheme();
  @override
  String get message => 'Seuls http et https sont acceptés.';
}

/// Point d'entrée réseau unique. Toute la chaîne passe par là, et l'implémentation
/// réelle n'est jamais utilisée dans un test.
abstract class ArticleFetcher {
  Future<FetchedPage> get(String url);
}

/// Implémentation réelle sur `dio`.
class DioArticleFetcher implements ArticleFetcher {
  DioArticleFetcher({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Pas plus de deux requêtes simultanées vers le même site : on ne veut pas
  /// se faire bannir d'un blog parce qu'on a ouvert vingt liens d'un coup.
  static const int maxConcurrentPerHost = 2;

  static const Duration timeout = Duration(seconds: 15);
  static const int maxBytes = 8 * 1024 * 1024;

  static const String userAgent =
      'ArticlesVersKindle/0.1 (+https://github.com/Tahlasandale/articles-kindle)';

  final Map<String, int> _inFlight = {};

  @override
  Future<FetchedPage> get(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FetchUnsupportedScheme();
    }

    await _acquireSlot(uri.host);
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: true,
          maxRedirects: 5,
          headers: const {'User-Agent': userAgent},
          receiveTimeout: timeout,
          sendTimeout: timeout,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final body = response.data ?? '';
      if (body.length > maxBytes) throw const FetchTooLarge();

      final length = response.headers.value('content-length');
      if (length != null && (int.tryParse(length) ?? 0) > maxBytes) {
        throw const FetchTooLarge();
      }

      return FetchedPage(
        url: response.realUri.toString(),
        body: body,
        statusCode: response.statusCode ?? 200,
        contentType: response.headers.value('content-type'),
      );
    } on DioException catch (e) {
      throw _translate(e);
    } finally {
      _releaseSlot(uri.host);
    }
  }

  FetchFailure _translate(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const FetchTimedOut(),
      DioExceptionType.connectionError => const NetworkUnavailable(),
      DioExceptionType.badResponse => FetchStatusError(
        e.response?.statusCode ?? 0,
      ),
      DioExceptionType.cancel => const NetworkUnavailable(),
      _ => const NetworkUnavailable(),
    };
  }

  Future<void> _acquireSlot(String host) async {
    while (true) {
      final current = _inFlight[host] ?? 0;
      if (current < maxConcurrentPerHost) {
        _inFlight[host] = current + 1;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void _releaseSlot(String host) {
    final current = _inFlight[host] ?? 1;
    if (current <= 1) {
      _inFlight.remove(host);
    } else {
      _inFlight[host] = current - 1;
    }
  }
}
