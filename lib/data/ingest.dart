import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/extraction/article_extraction_job.dart';
import 'package:articles_kindle/data/extraction/extraction_service.dart';

/// Ce qu'est devenu un lien après être entré.
class IngestOutcome {
  const IngestOutcome({
    required this.articleId,
    required this.status,
    this.reason,
    this.alreadyKnown = false,
  });

  final int articleId;
  final ArticleStatus status;
  final String? reason;

  /// Le lien était déjà dans la file : rien n'a été ré-extrait.
  final bool alreadyKnown;

  bool get isReady => status == ArticleStatus.ready;
  bool get isDuplicate => alreadyKnown;
}

/// Le chemin complet d'un lien : il entre dans la file, puis son contenu est
/// extrait. Les deux dans le même appel, sinon un article peut rester « en
/// attente » sans que rien ne le fasse avancer.
class ArticleIngest {
  ArticleIngest(this._articles, this._job);

  final ArticleService _articles;
  final ArticleExtractionJob _job;

  Future<IngestOutcome> addAndExtract(
    String url, {
    ArticleOrigin origin = ArticleOrigin.manual,
    String? contentFromFeed,
  }) async {
    final result = await _articles.addUrl(url, origin: origin);

    switch (result) {
      case ArticleInvalid(:final reason):
        // Rien n'a été écrit, il n'y a pas d'identifiant à rendre.
        return IngestOutcome(
          articleId: -1,
          status: ArticleStatus.failed,
          reason: reason,
        );
      case ArticleAlreadyKnown(:final article):
        // Un doublon n'est pas ré-extrait : le contenu est déjà là, ou l'a été.
        return IngestOutcome(
          articleId: article.id,
          status: ArticleStatus.fromName(article.status),
          alreadyKnown: true,
        );
      case ArticleAdded(:final article):
        final outcome = await _job.process(
          article.id,
          fromFeedContent: contentFromFeed,
        );
        return IngestOutcome(
          articleId: article.id,
          status: outcome is ExtractedArticle
              ? ArticleStatus.ready
              : ArticleStatus.failed,
          reason: outcome is ExtractionFailure ? outcome.reason : null,
        );
    }
  }

  /// Adding des articles choisis dans « articles du site ».
  Future<List<IngestOutcome>> addAll(
    Iterable<({String url, String? contentFromFeed})> items, {
    ArticleOrigin origin = ArticleOrigin.site,
  }) async {
    final results = <IngestOutcome>[];
    for (final item in items) {
      results.add(
        await addAndExtract(
          item.url,
          origin: origin,
          contentFromFeed: item.contentFromFeed,
        ),
      );
    }
    return results;
  }
}
