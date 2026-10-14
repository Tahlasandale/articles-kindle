import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:articles_kindle/data/epub/epub_builder.dart';
import 'package:flutter_test/flutter_test.dart';

const bodyHtml =
    '<p>Un paragraphe de l\'article, avec une <a href="https://exemple.fr/lien">'
    'référence</a> et une <em>insistance</em>.</p>';

EpubChapter chapter(int index, {String? title}) => EpubChapter(
  title: title ?? 'Article $index',
  url: 'https://exemple.fr/article-$index',
  contentHtml: bodyHtml,
  author: 'Auteur $index',
  siteName: 'Exemple',
  publishedAt: DateTime.utc(2026, 10, index),
  images: const [],
);

EpubBook bookWith(int chapters, {String title = 'Lectures du 14/10/2026'}) =>
    EpubBook(
      title: title,
      language: 'fr',
      identifier: 'urn:uuid:test-0000',
      createdAt: DateTime.utc(2026, 10, 14, 9),
      chapters: [for (var i = 1; i <= chapters; i++) chapter(i)],
    );

/// Lit les entrées du ZIP produit, dans l'ordre du fichier.
List<ArchiveFile> entriesOf(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  return archive.files;
}

String textOf(List<int> bytes, String name) {
  final file = entriesOf(bytes).firstWhere((f) => f.name == name);
  return utf8.decode(file.content as List<int>);
}

void main() {
  group('structure OCF', () {
    test('mimetype est la première entrée et n\'est pas compressé', () {
      final bytes = EpubBuilder().build(bookWith(1));

      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.files.first.name, 'mimetype');
      expect(
        archive.files.first.compression,
        CompressionType.none,
        reason: 'OFC exige mimetype stocké, pas deflate',
      );
    });

    test('le fichier mimetype a le bon contenu', () {
      final bytes = EpubBuilder().build(bookWith(1));
      expect(textOf(bytes, 'mimetype'), 'application/epub+zip');
    });

    test('container.xml désigne le paquet', () {
      final bytes = EpubBuilder().build(bookWith(1));
      final container = textOf(bytes, 'META-INF/container.xml');
      expect(container, contains('OEBPS/content.opf'));
      expect(container, contains('application/oebps-package+xml'));
    });

    test('chaque chapitre a son fichier', () {
      final bytes = EpubBuilder().build(bookWith(3));
      final names = entriesOf(bytes).map((f) => f.name).toList();
      expect(names, contains('OEBPS/chapters/ch001.xhtml'));
      expect(names, contains('OEBPS/chapters/ch003.xhtml'));
    });
  });

  group('métadonnées', () {
    test('content.opf porte le titre et le nombre de chapitres', () {
      final bytes = EpubBuilder().build(bookWith(3));
      final opf = textOf(bytes, 'OEBPS/content.opf');
      expect(opf, contains('<dc:title>Lectures du 14/10/2026</dc:title>'));
      expect(opf, contains('id="ch001"'));
      expect(opf, contains('id="ch003"'));
      expect(
        opf,
        isNot(contains('id="ch004"')),
        reason: 'trois chapitres, pas quatre',
      );
    });

    test('la langue est déclarée en français', () {
      final bytes = EpubBuilder().build(bookWith(1));
      expect(textOf(bytes, 'OEBPS/content.opf'), contains('xml:lang="fr"'));
    });

    test('un identifiant unique évite que deux livres se confondent', () {
      final book = bookWith(1);
      final opf = textOf(EpubBuilder().build(book), 'OEBPS/content.opf');
      expect(opf, contains('urn:uuid:test-0000'));
    });
  });

  group('table des matières', () {
    test('nav liste les chapitres dans l\'ordre', () {
      final bytes = EpubBuilder().build(bookWith(3));
      final nav = textOf(bytes, 'OEBPS/nav.xhtml');
      expect(nav, contains('Article 1'));
      expect(nav, contains('Article 3'));
      expect(nav.indexOf('Article 1'), lessThan(nav.indexOf('Article 2')));
    });

    test('toc.ncx est présent pour la conversion Amazon', () {
      final bytes = EpubBuilder().build(bookWith(2));
      final ncx = textOf(bytes, 'OEBPS/toc.ncx');
      expect(ncx, contains('<content src='));
      expect(ncx, contains('Article 1'));
    });
  });

  group('chapitres', () {
    test('le XHTML est bien formé et complet', () {
      final bytes = EpubBuilder().build(bookWith(1));
      final xhtml = textOf(bytes, 'OEBPS/chapters/ch001.xhtml');

      expect(xhtml, startsWith('<?xml version="1.0" encoding="utf-8"?>'));
      expect(xhtml, contains('<html xmlns="http://www.w3.org/1999/xhtml"'));
      expect(xhtml, contains('xmlns:epub="http://www.idpf.org/2007/ops"'));
      expect(xhtml.trimRight().endsWith('</html>'), isTrue);
    });

    test('chaque chapitre porte titre, source, auteur, date et lien', () {
      final bytes = EpubBuilder().build(bookWith(1));
      final xhtml = textOf(bytes, 'OEBPS/chapters/ch001.xhtml');

      expect(xhtml, contains('Article 1'));
      expect(xhtml, contains('Auteur 1'));
      expect(xhtml, contains('Exemple'));
      expect(xhtml, contains('2026'));
      expect(xhtml, contains('https://exemple.fr/article-1'));
    });

    test('le contenu extrait est repris tel quel', () {
      final bytes = EpubBuilder().build(bookWith(1));
      final xhtml = textOf(bytes, 'OEBPS/chapters/ch001.xhtml');

      expect(xhtml, contains('Un paragraphe de l\'article'));
      expect(xhtml, contains('<em>insistance</em>'));
    });

    test('les images téléchargées sont déclarées au manifeste', () {
      final book = bookWith(1);
      final withImage = EpubBook(
        title: book.title,
        language: book.language,
        identifier: book.identifier,
        createdAt: book.createdAt,
        chapters: [
          EpubChapter(
            title: 'Avec image',
            url: 'https://exemple.fr/a',
            contentHtml:
                '<p>Texte</p><img src="images/001-01.jpg" alt="Photo"/>',
            images: [
              EpubImage(
                fileName: '001-01.jpg',
                bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
                mimeType: 'image/jpeg',
              ),
            ],
          ),
        ],
      );

      final bytes = EpubBuilder().build(withImage);

      expect(
        textOf(bytes, 'OEBPS/content.opf'),
        contains('href="images/001-01.jpg"'),
      );
      final imageFile = entriesOf(bytes)
          .firstWhere((f) => f.name == 'OEBPS/images/001-01.jpg');
      expect(
        imageFile.content,
        isNotEmpty,
        reason: 'les octets JPEG sont dans l\'archive',
      );
    });
  });

  group('style e-ink', () {
    test('la feuille de style ne dépend d\'aucune police embarquée', () {
      final css = EpubBuilder.stylesheet;

      expect(css, contains('font-family'));
      expect(css.toLowerCase(), contains('georgia'));
      expect(css.toLowerCase(), isNot(contains('@font-face')));
    });
  });

  group('estimation de taille', () {
    test('est cohérente avec le fichier produit', () {
      final bytes = EpubBuilder().build(bookWith(4));
      final estimate = EpubBuilder.estimateSize(bookWith(4));

      // L'estimation doit être du même ordre de grandeur que le résultat réel :
      // c'est elle qui déclenche l'alerte des 25 Mo.
      expect(estimate, greaterThan(bytes.length ~/ 2));
      expect(estimate, lessThan(bytes.length * 2));
    });
  });

  group('titre du livre', () {
    test('par défaut, il porte la date du jour', () {
      final title = EpubBuilder.defaultTitle(DateTime(2026, 10, 14));
      expect(title, 'Lectures du 14/10/2026');
    });

    test('un titre saisi est respecté', () {
      final book = bookWith(1, title: 'Rust, JS, Python');
      expect(
        textOf(EpubBuilder().build(book), 'OEBPS/content.opf'),
        contains('<dc:title>Rust, JS, Python</dc:title>'),
      );
    });
  });

  group('livre vide', () {
    test('est refusé plutôt que produit', () {
      // epubcheck a montré qu'un livre sans chapitre est un EPUB invalide :
      // `spine`, `ol` et `navMap` exigent chacun au moins un enfant.
      expect(() => EpubBuilder().build(bookWith(0)), throwsStateError);
    });
  });

  group('écriture sur disque', () {
    test('écrit un fichier lisible à l\'emplacement demandé', () async {
      final directory = await Directory.systemTemp.createTemp('epub-test');
      addTearDown(() => directory.delete(recursive: true));

      final file = await EpubBuilder().writeTo(
        bookWith(2),
        directory,
        'lectures-du-14-10-2026.epub',
      );

      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(500));
      expect(
        textOf(await file.readAsBytes(), 'mimetype'),
        'application/epub+zip',
      );
    });
  });
}
