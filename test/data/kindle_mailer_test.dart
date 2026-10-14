import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/data/epub/epub_builder.dart';
import 'package:articles_kindle/data/mail/kindle_mailer.dart';
import 'package:articles_kindle/data/mail/mail_transport.dart';
import 'package:articles_kindle/data/secret_store.dart';
import 'package:articles_kindle/data/settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Transport factice : enregistre ce qui aurait été envoyé, n'envoie rien.
class FakeMailTransport implements MailTransport {
  final sent = <OutgoingMessage>[];

  @override
  Future<void> send(OutgoingMessage message) async => sent.add(message);
}

class FailingMailTransport implements MailTransport {
  FailingMailTransport(this.failure);

  final MailFailure failure;

  @override
  Future<void> send(OutgoingMessage message) async => throw failure;
}

class InMemorySecretStore implements SecretStore {
  InMemorySecretStore([this.password = 'mot-de-passe-application']);

  String? password;

  @override
  Future<void> writePassword(String value) async => password = value;

  @override
  Future<String?> readPassword() async => password;

  @override
  Future<void> deletePassword() async => password = null;
}

void main() {
  late AppDatabase db;
  late ArticleService articles;
  late FakeMailTransport transport;
  late InMemorySecretStore secrets;

  Future<int> seedReady(String url) async {
    final result = await articles.addUrl(url);
    final id = (result as ArticleAdded).article.id;
    await articles.markReady(
      id,
      title: 'Article $url',
      contentHtml: '<p>Texte</p>',
    );
    return id;
  }

  KindleMailer mailerWith({MailTransport? other}) => KindleMailer(
    transport: other ?? transport,
    articles: articles,
    secrets: secrets,
    settings: const AppSettings(
      kindleAddress: 'moi@kindle.com',
      smtpUsername: 'moi@gmail.com',
      smtpSender: 'moi@gmail.com',
    ),
    bookTitle: 'Lectures du 14/10/2026',
    now: () => DateTime.utc(2026, 10, 14, 9),
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    articles = ArticleService(db);
    transport = FakeMailTransport();
    secrets = InMemorySecretStore();
  });
  tearDown(() => db.close());

  group('envoi', () {
    test('un message part avec le livre en pièce jointe', () async {
      await seedReady('https://exemple.fr/a');
      await seedReady('https://exemple.fr/b');

      final result = await mailerWith().send();

      expect(result, isA<SendSucceeded>());
      expect(transport.sent, hasLength(1));
      final message = transport.sent.single;
      expect(message.to, 'moi@kindle.com');
      expect(message.from, 'moi@gmail.com');
      expect(message.attachments, hasLength(1));
      expect(
        message.attachments.single.fileName,
        'lectures-du-14-10-2026.epub',
      );
      expect(message.attachments.single.bytes, isNotEmpty);
    });

    test('le corps du message est vide, Amazon n\'en a pas besoin', () async {
      await seedReady('https://exemple.fr/a');
      await mailerWith().send();

      expect(transport.sent.single.text.trim(), isEmpty);
    });

    test('après succès, les articles passent à envoyés', () async {
      final a = await seedReady('https://exemple.fr/a');
      final b = await seedReady('https://exemple.fr/b');

      await mailerWith().send();

      final queue = await articles.sendQueue();
      expect(queue, isEmpty);
      final rows = await db.select(db.articles).get();
      expect(rows.every((r) => r.status == 'sent'), isTrue);
      expect(rows.every((r) => r.sentAt != null), isTrue);
      expect(rows.map((r) => r.id), containsAll([a, b]));
    });

    test('la livraison est journalisée', () async {
      await seedReady('https://exemple.fr/a');
      await mailerWith().send();

      final delivery = await db.select(db.deliveries).getSingle();
      expect(delivery.success, isTrue);
      expect(delivery.articleCount, 1);
      expect(delivery.fileSize, greaterThan(0));
      expect(delivery.error, isNull);
    });
  });

  group('échecs', () {
    test('rien n\'est marqué envoyé si le serveur refuse', () async {
      await seedReady('https://exemple.fr/a');

      final result = await mailerWith(
        other: FailingMailTransport(const MailAuthenticationFailed()),
      ).send();

      expect(result, isA<SendFailed>());
      final row = await db.select(db.articles).getSingle();
      expect(row.status, isNot('sent'));
      expect(row.sentAt, isNull);
      expect(
        row.selected,
        isTrue,
        reason: 'l\'article reste cochable pour réessayer',
      );
    });

    test('l\'échec est journalisé avec sa cause', () async {
      await seedReady('https://exemple.fr/a');

      await mailerWith(
        other: FailingMailTransport(const MailAuthenticationFailed()),
      ).send();

      final delivery = await db.select(db.deliveries).getSingle();
      expect(delivery.success, isFalse);
      expect(delivery.error, isNotNull);
    });

    test('sans mot de passe, rien n\'est envoyé', () async {
      await seedReady('https://exemple.fr/a');
      secrets.password = null;

      final result = await mailerWith().send();

      expect(result, isA<SendFailed>());
      expect(transport.sent, isEmpty);
    });

    test('sans adresse Kindle, rien n\'est envoyé', () async {
      await seedReady('https://exemple.fr/a');
      final mailer = KindleMailer(
        transport: transport,
        articles: articles,
        secrets: secrets,
        settings: const AppSettings(
          smtpUsername: 'moi@gmail.com',
          smtpSender: 'moi@gmail.com',
        ),
        bookTitle: 'Lectures',
        now: () => DateTime.utc(2026, 10, 14),
      );

      final result = await mailer.send();

      expect(result, isA<SendFailed>());
      expect(transport.sent, isEmpty);
    });

    test('sans article prêt, rien n\'est envoyé', () async {
      final result = await mailerWith().send();

      expect(result, isA<SendFailed>());
      expect(transport.sent, isEmpty);
    });
  });

  group('test d\'envoi', () {
    test('envoie un mini livre à l\'adresse Kindle', () async {
      final result = await mailerWith().sendTest();

      expect(result, isA<SendSucceeded>());
      final message = transport.sent.single;
      expect(message.attachments.single.fileName, 'test-epubcheck.epub');
      expect(message.attachments.single.bytes.length, lessThan(20000));
    });
  });

  group('estimation', () {
    test('est connue avant d\'envoyer', () async {
      await seedReady('https://exemple.fr/a');
      await seedReady('https://exemple.fr/b');

      final mailer = mailerWith();
      final estimate = await mailer.estimate();

      expect(estimate.articles, 2);
      expect(estimate.bytes, greaterThan(0));
    });
  });

  group('livre assemblé', () {
    test('chaque article devient un chapitre dans l\'ordre choisi', () async {
      await seedReady('https://exemple.fr/a');
      await seedReady('https://exemple.fr/b');
      final book = await mailerWith().buildBook();

      expect(book.chapters, hasLength(2));
      expect(book.chapters.first.url, 'https://exemple.fr/a');
      expect(book.chapters.last.url, 'https://exemple.fr/b');
      expect(book.title, 'Lectures du 14/10/2026');
    });

    test('le livre produit est un EPUB valide', () async {
      await seedReady('https://exemple.fr/a');
      final book = await mailerWith().buildBook();

      expect(() => EpubBuilder().build(book), returnsNormally);
    });
  });
}
