import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Une image téléchargée et déjà redimensionnée.
class EpubImage {
  const EpubImage({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
  });

  final String fileName;
  final List<int> bytes;
  final String mimeType;
}

/// Un article devenu chapitre.
class EpubChapter {
  const EpubChapter({
    required this.title,
    required this.url,
    required this.contentHtml,
    this.author,
    this.siteName,
    this.publishedAt,
    this.images = const [],
  });

  final String title;
  final String url;
  final String contentHtml;
  final String? author;
  final String? siteName;
  final DateTime? publishedAt;
  final List<EpubImage> images;
}

/// Tout ce qu'il faut pour fabriquer un livre.
class EpubBook {
  const EpubBook({
    required this.title,
    required this.language,
    required this.identifier,
    required this.createdAt,
    required this.chapters,
  });

  final String title;
  final String language;

  /// Un identifiant unique par livre : deux « Lectures du 14/10 » doivent rester
  /// deux livres distincts chez Amazon.
  final String identifier;
  final DateTime createdAt;
  final List<EpubChapter> chapters;
}

/// EPUB 3 fabriqué à la main.
///
/// Aucun paquet Dart de génération EPUB n'est fiable (voir DECISIONS.md) : la
/// structure OCF est écrite ici, et chaque sortie passe `epubcheck`.
class EpubBuilder {
  EpubBuilder();

  static const String _root = 'OEBPS';

  /// Feuille de style pensée pour un écran de 6 pouces en niveaux de gris.
  /// Aucune police embarquée : le Kindle 7e génération supprime celles-ci.
  static const String stylesheet = '''
body {
  font-family: Georgia, "Times New Roman", serif;
  font-size: 11.5pt;
  line-height: 1.5;
  margin: 0 5%;
  text-align: justify;
  hyphens: auto;
}
h1 {
  font-size: 17pt;
  line-height: 1.25;
  margin: 1.2em 0 0.2em;
  text-align: left;
  hyphens: none;
}
h2, h3, h4 {
  font-size: 13pt;
  line-height: 1.3;
  margin: 1.1em 0 0.2em;
  text-align: left;
  hyphens: none;
}
p { margin: 0 0 0.7em; orphans: 2; widows: 2; }
a { color: inherit; text-decoration: underline; }
blockquote { margin: 1em 1.5em; font-style: italic; }
pre { font-family: monospace; font-size: 9.5pt; white-space: pre-wrap; }
code { font-family: monospace; font-size: 10pt; }
img { max-width: 100%; height: auto; }
figure { margin: 1em 0; text-align: center; }
figcaption { font-size: 9.5pt; font-style: italic; }
ul, ol { margin: 0 0 0.7em 1.2em; padding: 0; }
table { border-collapse: collapse; width: 100%; font-size: 10pt; }
td, th { border: 1px solid; padding: 0.2em 0.3em; }
.chapter-header {
  margin-bottom: 1.5em;
  font-size: 9.5pt;
  font-style: italic;
  text-align: left;
}
.chapter-source { display: block; }
''';

  static String defaultTitle(DateTime day) {
    final d =
        '${day.day.toString().padLeft(2, '0')}/'
        '${day.month.toString().padLeft(2, '0')}/${day.year}';
    return 'Lectures du $d';
  }

  /// Estimation grossière, pour l'alerte des 25 Mo avant d'envoyer.
  static int estimateSize(EpubBook book) {
    var total = 0;
    for (final chapter in book.chapters) {
      total += chapter.contentHtml.length + 900; // en-tête et navigation
      for (final image in chapter.images) {
        total += image.bytes.length;
      }
    }
    return total;
  }

  List<int> build(EpubBook book) {
    // Un livre sans chapitre est un EPUB invalide : `spine`, `ol` et `navMap`
    // exigent chacun au moins un enfant. Mieux vaut une exception ici qu'un
    // fichier refusé par Amazon trois minutes après l'envoi.
    if (book.chapters.isEmpty) {
      throw StateError('Un livre doit contenir au moins un article');
    }

    final archive = Archive();

    // Contrainte OCF : mimetype en première entrée, non compressée. Amazon et
    // `epubcheck` refusent le fichier sinon.
    final mimetype = utf8.encode('application/epub+zip');
    archive.addFile(
      ArchiveFile.noCompress('mimetype', mimetype.length, mimetype),
    );

    _add(archive, 'META-INF/container.xml', _containerXml);
    _add(archive, '$_root/styles.css', stylesheet);
    _add(archive, '$_root/nav.xhtml', _nav(book));
    _add(archive, '$_root/toc.ncx', _ncx(book));
    _add(archive, '$_root/content.opf', _opf(book));

    for (var i = 0; i < book.chapters.length; i++) {
      final chapter = book.chapters[i];
      final name = 'ch${(i + 1).toString().padLeft(3, '0')}';
      _add(archive, '$_root/chapters/$name.xhtml', _chapter(chapter, name, i));

      for (final image in chapter.images) {
        _addBytes(archive, '$_root/images/${image.fileName}', image.bytes);
      }
    }

    return ZipEncoder().encodeBytes(archive);
  }

  Future<File> writeTo(
    EpubBook book,
    Directory directory,
    String fileName,
  ) async {
    final bytes = build(book);
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _add(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  void _addBytes(Archive archive, String name, List<int> bytes) {
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  // --- Déclarations XML ----------------------------------------------------

  static const String _containerXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
              media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';

  String _opf(EpubBook book) {
    final manifest = <String>[];
    final spine = <String>[];

    manifest.add(
      '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
    );
    manifest.add(
      '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>',
    );
    manifest.add('<item id="css" href="styles.css" media-type="text/css"/>');

    for (var i = 0; i < book.chapters.length; i++) {
      final name = 'ch${(i + 1).toString().padLeft(3, '0')}';
      manifest.add(
        '<item id="$name" href="chapters/$name.xhtml" media-type="application/xhtml+xml"/>',
      );
      spine.add('<itemref idref="$name"/>');

      for (final image in book.chapters[i].images) {
        final id = 'img-$name-${image.fileName.replaceAll('.', '-')}';
        manifest.add(
          '<item id="$id" href="images/${image.fileName}" media-type="${image.mimeType}"/>',
        );
      }
    }

    return '''
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0"
         unique-identifier="pub-id" xml:lang="${_escape(book.language)}">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="pub-id">${_escape(book.identifier)}</dc:identifier>
    <dc:title>${_escape(book.title)}</dc:title>
    <dc:language>${_escape(book.language)}</dc:language>
    <dc:creator>Lectures</dc:creator>
    <meta property="dcterms:modified">${_stamp(book.createdAt)}</meta>
    <meta name="cover" content=""/>
  </metadata>
  <manifest>
${manifest.map((e) => '    $e').join('\n')}
  </manifest>
  <spine toc="ncx">
${spine.map((e) => '    $e').join('\n')}
  </spine>
</package>
''';
  }

  String _nav(EpubBook book) {
    final items = <String>[];
    for (var i = 0; i < book.chapters.length; i++) {
      final name = 'ch${(i + 1).toString().padLeft(3, '0')}';
      items.add(
        '      <li><a href="chapters/$name.xhtml">${_escape(book.chapters[i].title)}</a></li>',
      );
    }

    return '''
<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"
      xml:lang="${_escape(book.language)}">
<head>
  <title>${_escape(book.title)}</title>
  <meta charset="utf-8"/>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <nav epub:type="toc" id="toc">
    <h1>Sommaire</h1>
    <ol>
${items.join('\n')}
    </ol>
  </nav>
</body>
</html>
''';
  }

  String _ncx(EpubBook book) {
    final points = <String>[];
    for (var i = 0; i < book.chapters.length; i++) {
      final name = 'ch${(i + 1).toString().padLeft(3, '0')}';
      points.add('''
    <navPoint id="nav-$name" playOrder="${i + 1}">
      <navLabel><text>${_escape(book.chapters[i].title)}</text></navLabel>
      <content src="chapters/$name.xhtml"/>
    </navPoint>''');
    }

    return '''
<?xml version="1.0" encoding="utf-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1"
     xml:lang="${_escape(book.language)}">
  <head>
    <meta name="dtb:uid" content="${_escape(book.identifier)}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle><text>${_escape(book.title)}</text></docTitle>
  <navMap>
${points.join('\n')}
  </navMap>
</ncx>
''';
  }

  String _chapter(EpubChapter chapter, String fileName, int index) {
    final header = <String>[];
    if (chapter.siteName != null && chapter.siteName!.isNotEmpty) {
      header.add(
        '<span class="chapter-source">${_escape(chapter.siteName!)}</span>',
      );
    }
    if (chapter.author != null && chapter.author!.isNotEmpty) {
      header.add(_escape(chapter.author!));
    }
    if (chapter.publishedAt != null) {
      header.add(_date(chapter.publishedAt!));
    }
    header.add('<a href="${_escape(chapter.url)}">${_escape(chapter.url)}</a>');

    return '''
<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"
      xml:lang="fr">
<head>
  <title>${_escape(chapter.title)}</title>
  <meta charset="utf-8"/>
  <link rel="stylesheet" type="text/css" href="../styles.css"/>
</head>
<body epub:type="bodymatter">
  <section epub:type="chapter" id="$fileName">
    <h1>${_escape(chapter.title)}</h1>
    <p class="chapter-header">${header.join(' · ')}</p>
    ${chapter.contentHtml}
  </section>
</body>
</html>
''';
  }

  // --- Utilitaires ----------------------------------------------------------

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _stamp(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}T'
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}:'
      '${value.second.toString().padLeft(2, '0')}Z';

  /// L'archive est construite entièrement en mémoire : le contenu d'un livre
  /// tient largement dans les quelques dizaines de mégaoctets que Kindle accepte.
  Uint8List buildBytes(EpubBook book) => Uint8List.fromList(build(book));
}
