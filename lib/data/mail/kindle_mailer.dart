import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/epub/epub_builder.dart';
import 'package:articles_kindle/data/mail/mail_transport.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:articles_kindle/data/settings.dart';

/// Résultat d'un envoi, tel que l'écran peut le raconter.
sealed class SendOutcome {
  const SendOutcome();
}

class SendSucceeded extends SendOutcome {
  const SendSucceeded(this.articles, this.bytes);

  final int articles;
  final int bytes;
}

class SendFailed extends SendOutcome {
  const SendFailed(this.reason);

  final String reason;
}

/// Taille et contenu du livre avant de partir.
class SendEstimate {
  const SendEstimate({required this.articles, required this.bytes});

  final int articles;
  final int bytes;
}

/// Assemble le livre, l'envoie, et met la base dans le bon état.
///
/// Un échec ne marque rien : c'est la règle qui permet de réessayer sans rien
/// ressaisir.
class KindleMailer {
  KindleMailer({
    required this._transport,
    required this.articles,
    required this.secrets,
    required this.settings,
    required this.bookTitle,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MailTransport _transport;
  final ArticleService articles;
  final SecretStore secrets;
  final AppSettings settings;
  final String bookTitle;
  final DateTime Function() _now;

  Future<SendEstimate> estimate() async {
    final queue = await articles.sendQueue();
    return SendEstimate(
      articles: queue.length,
      bytes: EpubBuilder.estimateSize(await buildBook()),
    );
  }

  /// Le livre tel qu'il sera envoyé, dans l'ordre choisi à l'écran d'envoi.
  Future<EpubBook> buildBook() async {
    final queue = await articles.sendQueue();
    final title = bookTitle.isNotEmpty
        ? bookTitle
        : EpubBuilder.defaultTitle(_now());

    return EpubBook(
      title: title,
      language: 'fr',
      identifier: _identifierFor(title),
      createdAt: DateTime.now().toUtc(),
      chapters: [
        for (final article in queue)
          EpubChapter(
            title: article.title ?? article.url,
            url: article.url,
            contentHtml: article.contentHtml ?? '',
            author: article.author,
            siteName: article.siteName,
            publishedAt: article.publishedAt,
          ),
      ],
    );
  }

  Future<SendOutcome> send() async {
    final queue = await articles.sendQueue();
    if (queue.isEmpty) {
      return const SendFailed('Aucun article prêt à envoyer.');
    }

    final password = await secrets.readPassword();
    if (password == null || password.isEmpty) {
      return const SendFailed(
        'Le mot de passe d\'application n\'est pas enregistré.',
      );
    }
    if (!settings.kindleAddress.contains('@')) {
      return const SendFailed('L\'adresse Kindle n\'est pas renseignée.');
    }

    final EpubBook book;
    try {
      book = await buildBook();
    } on StateError catch (e) {
      return SendFailed(e.message);
    }

    final bytes = EpubBuilder().build(book);
    final fileName = epubFileName(book.title);

    try {
      await _transport.send(
        OutgoingMessage(
          from: settings.smtpSender.isNotEmpty
              ? settings.smtpSender
              : settings.smtpUsername,
          to: settings.kindleAddress,
          attachments: [MailAttachment(fileName: fileName, bytes: bytes)],
        ),
      );
    } on MailFailure catch (failure) {
      await articles.recordDelivery(
        articleCount: queue.length,
        fileSize: 0,
        success: false,
        error: failure.reason,
      );
      return SendFailed(failure.reason);
    } catch (error) {
      await articles.recordDelivery(
        articleCount: queue.length,
        fileSize: 0,
        success: false,
        error: '$error',
      );
      return SendFailed('$error');
    }

    await articles.markSent([for (final a in queue) a.id]);
    await articles.recordDelivery(
      articleCount: queue.length,
      fileSize: bytes.length,
      success: true,
    );
    return SendSucceeded(queue.length, bytes.length);
  }

  /// Envoie un livre minuscule à l'adresse Kindle. Sert à vérifier que le
  /// serveur SMTP et l'expéditeur sont acceptés avant de positer un vrai livre.
  Future<SendOutcome> sendTest() async {
    final password = await secrets.readPassword();
    if (password == null || password.isEmpty) {
      return const SendFailed(
        'Le mot de passe d\'application n\'est pas enregistré.',
      );
    }
    if (!settings.kindleAddress.contains('@')) {
      return const SendFailed('L\'adresse Kindle n\'est pas renseignée.');
    }

    final book = EpubBook(
      title: 'Test d\'envoi',
      language: 'fr',
      identifier: _identifierFor('test-${_now().millisecondsSinceEpoch}'),
      createdAt: DateTime.now().toUtc(),
      chapters: const [
        EpubChapter(
          title: 'Test d\'envoi',
          url: 'https://github.com/Tahlasandale/articles-kindle',
          contentHtml:
              '<p>Si ce livre arrive dans votre Kindle, l\'envoi '
              'fonctionne. Vous pouvez le supprimer.</p>',
        ),
      ],
    );

    final bytes = EpubBuilder().build(book);
    try {
      await _transport.send(
        OutgoingMessage(
          from: settings.smtpSender.isNotEmpty
              ? settings.smtpSender
              : settings.smtpUsername,
          to: settings.kindleAddress,
          attachments: [
            MailAttachment(fileName: 'test-epubcheck.epub', bytes: bytes),
          ],
        ),
      );
    } on MailFailure catch (failure) {
      return SendFailed(failure.reason);
    }
    return SendSucceeded(1, bytes.length);
  }

  /// Amazon identifie un livre par son titre ; deux envois du même jour doivent
  /// rester deux livres distincts.
  String _identifierFor(String title) =>
      'urn:uuid:${title.hashCode.toUnsigned(32).toRadixString(16)}-'
      '${_now().millisecondsSinceEpoch.toRadixString(16)}';
}
