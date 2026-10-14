import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/extraction/extraction_service.dart';

/// Fait le lien entre l'extraction et la base : un article est soit « prêt » avec
/// son contenu, soit « en échec » avec une raison, et rien d'autre ne bouge.
///
/// Le traitement lourd part dans un isolate côté interface ; ici on ne fait que
/// la règle métier, ce qui la rend testable en Dart pur.
class ArticleExtractionJob {
  ArticleExtractionJob(this._articles, this._extraction);

  final ArticleService _articles;
  final ExtractionService _extraction;

  /// Traite un article. `fromFeedContent` court-circuite le téléchargement quand
  /// le flux du site fournissait déjà le texte complet.
  Future<ExtractionOutcome> process(
    int articleId, {
    String? fromFeedContent,
  }) async {
    final article = await _articles.findById(articleId);
    if (article == null) {
      return ExtractionFailure('Article introuvable');
    }

    if (fromFeedContent != null && fromFeedContent.trim().isNotEmpty) {
      await _articles.markReady(
        articleId,
        title: article.title,
        contentHtml: fromFeedContent,
        contentSource: ContentSource.feed,
      );
      return ExtractedArticle(
        title: article.title,
        contentHtml: fromFeedContent,
        plainText: fromFeedContent,
      );
    }

    final outcome = await _extraction.fetchAndExtract(article.url);

    switch (outcome) {
      case ExtractionFailure(:final reason):
        await _articles.markFailed(articleId, error: reason);
        return outcome;
      case ExtractedArticle():
        await _articles.markReady(
          articleId,
          title: outcome.title,
          author: outcome.author,
          siteName: outcome.siteName,
          publishedAt: outcome.publishedAt,
          contentHtml: outcome.contentHtml,
        );
        return outcome;
    }
  }

  /// Traite plusieurs articles sans qu'un échec arrête les autres.
  Future<Map<int, ExtractionOutcome>> processAll(List<int> articleIds) async {
    final results = <int, ExtractionOutcome>{};
    for (final id in articleIds) {
      results[id] = await process(id);
    }
    return results;
  }
}
