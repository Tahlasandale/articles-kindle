import 'package:articles_kindle/app.dart';
import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Surcharge la base par une base en mémoire : aucun test de widget ne touche
/// au fichier de l'appareil.
ProviderContainer containerWithMemoryDatabase() {
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
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
}) async {
  final service = container.read(articleServiceProvider);
  final result = await service.addUrl(url);
  final article = (result as ArticleAdded).article;
  await service.markReady(
    article.id,
    title: title,
    contentHtml: '<p>Texte</p>',
  );
  return article;
}
