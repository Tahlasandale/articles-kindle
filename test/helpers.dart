import 'package:articles_kindle/app.dart';
import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class InMemorySecretStore implements SecretStore {
  InMemorySecretStore([this.password = 'mot-de-passe-application']);

  String? password;

  @override
  Future<String?> readPassword() async => password;

  @override
  Future<void> writePassword(String nextPassword) async {
    password = nextPassword;
  }

  @override
  Future<void> deletePassword() async {
    password = null;
  }
}

/// Surcharge la base par une base en mémoire : aucun test de widget ne touche
/// au fichier de l'appareil.
ProviderContainer containerWithMemoryDatabase({
  List<dynamic> overrides = const [],
}) {
  final hasSecret = overrides.any((o) {
    try {
      return (o as dynamic).origin == secretStoreProvider;
    } catch (_) {
      return false;
    }
  });

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
      if (!hasSecret)
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      ...overrides.cast(),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> pumpApp(
  WidgetTester tester, {
  ProviderContainer? container,
}) async {
  final providers = container ?? containerWithMemoryDatabase();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: providers,
      child: const ArticlesKindleApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Ajoute un article prêt à partir, pour éviter d'écrire le HTML dans chaque test.
Future<ArticleRow> seedReadyArticle(
  ProviderContainer container,
  String url, {
  String title = 'Un article',
  String contentHtml = '<p>Texte</p>',
}) async {
  final service = container.read(articleServiceProvider);
  final result = await service.addUrl(url);
  final article = (result as ArticleAdded).article;
  await service.markReady(article.id, title: title, contentHtml: contentHtml);
  return article;
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  String? loadedHtml;
  String? loadedBaseUrl;
  Color? backgroundColor;
  JavaScriptMode? javaScriptMode;

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    loadedHtml = html;
    loadedBaseUrl = baseUrl;
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    backgroundColor = color;
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {
    javaScriptMode = mode;
  }
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(key: Key('webview_widget'));
  }
}

class FakeWebViewPlatform extends WebViewPlatform {
  FakeWebViewController? lastController;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    lastController = FakeWebViewController(params);
    return lastController!;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakeWebViewWidget(params);
  }
}

FakeWebViewPlatform initFakeWebView() {
  final platform = FakeWebViewPlatform();
  WebViewPlatform.instance = platform;
  return platform;
}
