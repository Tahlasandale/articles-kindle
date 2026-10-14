import 'dart:io';

import 'package:articles_kindle/data/extraction/extraction_service.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux fetcher : sert une page en mémoire, rien d'autre. Aucun test de ce
/// fichier ne touche au réseau.
class FixtureFetcher implements ArticleFetcher {
  FixtureFetcher(this.html);

  final String html;
  final requested = <String>[];

  @override
  Future<FetchedPage> get(String url) async {
    requested.add(url);
    return FetchedPage(url: url, body: html, contentType: 'text/html');
  }
}

String fixture(String path) =>
    File('test/fixtures/html/$path').readAsStringSync();

ExtractionService serviceFor(String html) =>
    ExtractionService(FixtureFetcher(html));

FetchedPage pageOf(String html, [String url = 'https://exemple.fr/a']) =>
    FetchedPage(url: url, body: html, contentType: 'text/html');

/// Un article de moins de 400 caractères est refusé : les tests de nettoyage
/// utilisent donc un texte de longueur réelle plutôt que deux phrases.
String filler([int times = 8]) => List.filled(
  times,
  'Un paragraphe de longueur normale, avec une virgule, qui explique '
  'quelque chose au lecteur de l\'article et l\'éclaire sur le sujet.',
).join(' ');

/// Extrait et exige un succès : si l'extraction échoue, le test doit le dire
/// clairement plutôt que derenvoyer null par accident.
ExtractedArticle mustExtract(
  ExtractionService service,
  String html, {
  String url = 'https://exemple.fr/a',
}) {
  final outcome = service.extract(pageOf(html, url));
  if (outcome is ExtractionFailure) {
    fail('extraction refusée : ${outcome.reason}');
  }
  return outcome as ExtractedArticle;
}

void main() {
  group('propreté du HTML', () {
    test('retire script, style, formulaires et cadres', () {
      final html =
          '''
        <html><head><style>body{color:red}</style></head>
        <body>
          <script>alert(1)</script>
          <form action="/recherche"><input name="q"></form>
          <iframe src="https://pub.example/x"></iframe>
          <p>Le texte de l'article. ${filler()}</p>
        </body></html>''';

      final article = mustExtract(serviceFor(html), html);

      expect(article.contentHtml, isNot(contains('<script')));
      expect(article.contentHtml, isNot(contains('alert')));
      expect(article.contentHtml, isNot(contains('<style')));
      expect(article.contentHtml, isNot(contains('<form')));
      expect(article.contentHtml, isNot(contains('<iframe')));
      expect(article.contentHtml, contains('Le texte de l\'article.'));
    });

    test('retire les attributs d\'événements', () {
      final html =
          '<html><body><p onclick="voler()" onmouseover="x()">Bonjour ${filler()}</p></body></html>';

      final article = mustExtract(serviceFor(html), html);

      expect(article.contentHtml, isNot(contains('onclick')));
      expect(article.contentHtml, isNot(contains('onmouseover')));
      expect(article.contentHtml, contains('Bonjour'));
    });

    test('retire la navigation, l\'encart et le pied de page', () {
      final html =
          '''
        <html><body>
          <nav><a href="/a">Accueil</a><a href="/b">Articles</a></nav>
          <main><p>Le cœur de l'article. ${filler()}</p></main>
          <aside><p>Publicité</p></aside>
          <footer><p>Mentions légales</p></footer>
        </body></html>''';

      final article = mustExtract(serviceFor(html), html);

      expect(article.contentHtml, contains('Le cœur de l\'article.'));
      expect(article.contentHtml, isNot(contains('Mentions légales')));
      expect(article.contentHtml, isNot(contains('Publicité')));
    });

    test('rend les liens et les images absolus', () {
      final html =
          '''
        <html><body><main>
          <p><a href="/un-lien">Lien</a></p>
          <p>${filler()}</p>
          <p><img src="images/photo.jpg" alt="Une photo"></p>
        </main></body></html>''';

      final article = mustExtract(
        serviceFor(html),
        html,
        url: 'https://exemple.fr/blog/article.html',
      );

      expect(article.contentHtml, contains('https://exemple.fr/un-lien'));
      expect(
        article.contentHtml,
        contains('https://exemple.fr/blog/images/photo.jpg'),
      );
    });

    test('un texte déjà court est conservé tel quel', () {
      final html =
          '<html><body><article><p>Une phrase suffit. ${filler()}</p></article></body></html>';

      final article = mustExtract(serviceFor(html), html);

      expect(article.contentHtml, contains('Une phrase suffit.'));
    });
  });

  group('métadonnées', () {
    test('lit le titre de la balise title et de og:title', () {
      final html = '''
        <html><head><title>Le vrai titre — Le site</title>
        <meta property="og:title" content="Le vrai titre"></head>
        <body><article><p>${filler(10)}</p></article></body></html>''';

      final article = mustExtract(serviceFor(html), html);

      expect(article.title, 'Le vrai titre');
    });

    test('retire le nom du site du début du titre', () {
      final html = '''
        <html><head><title>Korben.info - Un article au hasard</title></head>
        <body><article><p>${filler(10)}</p></article></body></html>''';

      final article = mustExtract(
        serviceFor(html),
        html,
        url: 'https://korben.info/a',
      );

      expect(article.title, 'Un article au hasard');
    });

    test('lit le nom du site et l\'auteur', () {
      final html = '''
        <html><head>
          <meta property="og:site_name" content="Framablog">
          <meta name="author" content="Le Dune">
        </head>
        <body><article><p>${filler(10)}</p></article></body></html>''';

      final article = mustExtract(serviceFor(html), html);

      expect(article.siteName, 'Framablog');
      expect(article.author, 'Le Dune');
    });

    test('reconnaît une date de publication', () {
      final html = '''
        <html><head>
          <meta property="article:published_time" content="2026-10-12T08:30:00+00:00">
        </head>
        <body><article><p>${filler(10)}</p></article></body></html>''';

      final article = mustExtract(serviceFor(html), html);

      expect(article.publishedAt, isNotNull);
      expect(article.publishedAt!.year, 2026);
    });
  });

  group('échecs propres', () {
    test('une page sans contenu exploitable est signalée', () {
      const html =
          '<html><head><title>App</title></head><body><div id="root"></div></body></html>';

      expect(serviceFor(html).extract(pageOf(html)), isA<ExtractionFailure>());
    });

    test('une page vide est signalée', () {
      expect(serviceFor('').extract(pageOf('')), isA<ExtractionFailure>());
    });

    test('une erreur réseau devient un échec, pas une exception', () async {
      final service = ExtractionService(_FailingFetcher());
      final outcome = await service.fetchAndExtract('https://exemple.fr/a');

      expect(outcome, isA<ExtractionFailure>());
    });
  });

  group('corpus réel', () {
    // Le cœur du projet : ces pages sont vraies et le sont restées.
    const cases = <String, String>{
      'korben/ported2browser-200-jeux-dans-le-navigateur.html':
          'un article court noyé dans la navigation',
      'selfh.st/weekly-2026-10-09.html': 'un blog auto-hébergé',
      'lemotdejay/le-cirad-revient-a-la-maison.html': 'un blog Ghost',
      'code.gouv.fr/bluehat-terreze.html': 'un site institutionnel',
      'blog-stephane-robert/chainguard-actions-plumber-securite-cicd.html':
          'beaucoup de menu pour peu de texte',
    };

    cases.forEach((path, description) {
      test('extrait le texte utile de $description', () {
        final html = fixture(path);
        final article = mustExtract(serviceFor(html), html);

        expect(
          article.plainText.length,
          greaterThan(600),
          reason: 'trop peu de texte extrait de $path',
        );
        expect(article.title, isNotNull, reason: 'titre manquant sur $path');
      });
    });

    test('chaque fixture du corpus donne du texte ou un refus net', () {
      final directory = Directory('test/fixtures/html');
      final files = directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.html'))
          .toList();

      expect(
        files.length,
        greaterThanOrEqualTo(30),
        reason: 'le corpus a rétréci',
      );

      for (final file in files) {
        final html = file.readAsStringSync();
        final outcome = serviceFor(html)
            .extract(pageOf(html, 'https://exemple.fr/a'));

        if (outcome is ExtractedArticle) {
          // Du texte, pas une feuille de style : un EPUB rempli de '{' n'est
          // pas un livre.
          expect(
            outcome.plainText.length,
            greaterThan(400),
            reason: 'texte trop court sur ${file.path}',
          );
          expect(
            outcome.plainText.contains('{'),
            isFalse,
            reason: 'feuille de style passée pour du texte : ${file.path}',
          );
          expect(
            outcome.contentHtml,
            isNot(contains('<script')),
            reason: 'script resté dans ${file.path}',
          );
        } else {
          expect(outcome, isA<ExtractionFailure>());
          expect(
            (outcome as ExtractionFailure).reason,
            isNotEmpty,
            reason: 'échec sans raison',
          );
        }
      }
    });
  });
}

class _FailingFetcher implements ArticleFetcher {
  @override
  Future<FetchedPage> get(String url) async => throw const FetchTimedOut();
}
