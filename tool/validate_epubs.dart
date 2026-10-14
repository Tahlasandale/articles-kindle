// Fabrique des EPUB à partir du corpus et les fait valider par epubcheck.
//
//   dart run tool/validate_epubs.dart [chemin/vers/epubcheck.jar]
//
// C'est la porte de la section 8 de la spec : un EPUB que nos tests acceptent peut
// être refusé par Amazon si la structure OCF est fausse. epubcheck, lui, lit la
// spécification.

import 'dart:io';

import 'package:articles_kindle/data/epub/epub_builder.dart';

Future<int> main(List<String> arguments) async {
  final jar = arguments.isNotEmpty
      ? arguments.first
      : 'tool/cache/epubcheck.jar';

  if (!File(jar).existsSync()) {
    stderr.writeln('epubcheck.jar introuvable : $jar');
    return 1;
  }

  final samples = <String, EpubBook>{
    'un-chapitre': EpubBook(
      title: 'Lectures du 14/10/2026',
      language: 'fr',
      identifier: 'urn:uuid:00000000-0000-4000-8000-000000000001',
      createdAt: DateTime.utc(2026, 10, 14, 9),
      chapters: [chapterOf(1)],
    ),
    'douze-chapitres': EpubBook(
      title: 'Lectures du 14/10/2026',
      language: 'fr',
      identifier: 'urn:uuid:00000000-0000-4000-8000-000000000002',
      createdAt: DateTime.utc(2026, 10, 14, 9),
      chapters: [for (var i = 1; i <= 12; i++) chapterOf(i)],
    ),
    'guillemets-et-accents': EpubBook(
      title: 'Rust, JS & Python : ce qu\'il faut savoir (2026)',
      language: 'fr',
      identifier: 'urn:uuid:00000000-0000-4000-8000-000000000003',
      createdAt: DateTime.utc(2026, 10, 14, 9),
      chapters: [
        const EpubChapter(
          title: 'Guillemets « à la française » & esperluettes & accents éàü',
          url: 'https://exemple.fr/article?a=1&b=2',
          author: 'Auteur & Co',
          siteName: 'Exemple',
          contentHtml:
              '<p>Un texte avec des &amp; et des &lt;balises&gt;.</p>'
              '<ul><li>Un item</li><li>Un autre</li></ul>'
              '<blockquote>Une citation</blockquote>'
              '<p>Un lien <a href="https://exemple.fr/x">vers ailleurs</a>.</p>',
        ),
      ],
    ),
  };

  final directory = await Directory.systemTemp.createTemp('epubcheck');
  try {
    final failures = <String>[];

    samples.forEach((name, book) {
      final file = File('${directory.path}/$name.epub');
      file.writeAsBytesSync(EpubBuilder().build(book));

      final result = Process.runSync('java', ['-jar', jar, file.path]);
      final output = '${result.stdout}${result.stderr}';

      final invalid = result.exitCode != 0;
      if (invalid) failures.add('$name (code ${result.exitCode})');

      // ignore: avoid_print
      print(
        '${invalid ? 'ÉCHEC' : 'ok  '} $name — ${file.lengthSync()} octets',
      );
      if (invalid) {
        // ignore: avoid_print
        print(output.split('\n').take(25).join('\n'));
      }
    });

    if (failures.isNotEmpty) {
      stderr.writeln('\nepubcheck a refusé : ${failures.join(', ')}');
      return 1;
    }

    // ignore: avoid_print
    print('\nTous les EPUB sont valides.');
    return 0;
  } finally {
    await directory.delete(recursive: true);
  }
}

EpubChapter chapterOf(int index) => EpubChapter(
  title: 'Article $index',
  url: 'https://exemple.fr/article-$index',
  contentHtml:
      '<h2>Une section</h2>'
      '<p>Un paragraphe de l\'article numéro $index, avec un '
      '<a href="https://exemple.fr/lien">lien</a> et une '
      '<em>insistance</em>.</p>'
      '<p>Un second paragraphe, pour que le chapitre ressemble à un vrai '
      'article et non à une ligne de test.</p>'
      '<ul><li>Premier point</li><li>Second point</li></ul>',
  author: 'Auteur $index',
  siteName: 'Exemple',
  publishedAt: DateTime.utc(2026, 10, index),
);
