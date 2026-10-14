import 'dart:io';

import 'package:articles_kindle/data/mail/mail_transport.dart';
import 'package:articles_kindle/data/mail/smtp_mail_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailer/mailer.dart' as mailer;

void main() {
  group('SmtpMailTransport', () {
    test('refuse d\'envoyer si TLS est désactivé', () async {
      final transport = SmtpMailTransport(
        host: 'smtp.gmail.com',
        port: 587,
        username: 'user@example.com',
        password: 'secret',
        useTls: false,
      );

      expect(
        () => transport.send(
          const OutgoingMessage(
            from: 'user@example.com',
            to: 'kindle@example.com',
          ),
        ),
        throwsA(isA<MailConfigurationIncomplete>()),
      );
    });

    test('utilise le passwordProvider pour récupérer le mot de passe dynamiquement', () async {
      var providerCalled = false;
      final transport = SmtpMailTransport(
        host: 'smtp.gmail.com',
        port: 587,
        username: 'user@example.com',
        passwordProvider: () async {
          providerCalled = true;
          return 'secret-dynamique';
        },
        useTls: true,
      );

      expect(transport.passwordProvider, isNotNull);
      final pwd = await transport.resolvePassword();
      expect(pwd, 'secret-dynamique');
      expect(providerCalled, isTrue);
    });

    test('rejette l\'envoi avec MailAuthenticationFailed si le mot de passe est vide', () async {
      final transport = SmtpMailTransport(
        host: 'smtp.gmail.com',
        port: 587,
        username: 'user@example.com',
        passwordProvider: () async => '',
        useTls: true,
      );

      expect(
        () => transport.send(
          const OutgoingMessage(
            from: 'user@example.com',
            to: 'kindle@example.com',
          ),
        ),
        throwsA(isA<MailAuthenticationFailed>()),
      );
    });

    test(
      'mappe SmtpClientAuthenticationException en MailAuthenticationFailed',
      () {
        final failure = SmtpMailTransport.mapException(
          mailer.SmtpClientAuthenticationException(
            '535 5.7.8 Username and Password not accepted',
          ),
        );
        expect(failure, isA<MailAuthenticationFailed>());
      },
    );

    test(
      'mappe SmtpClientCommunicationException 535 en MailAuthenticationFailed',
      () {
        final failure = SmtpMailTransport.mapException(
          mailer.SmtpClientCommunicationException(
            '535 Authentication credentials invalid',
          ),
        );
        expect(failure, isA<MailAuthenticationFailed>());
      },
    );

    test('mappe SmtpClientCommunicationException 550 en MailServerRefused', () {
      final failure = SmtpMailTransport.mapException(
        mailer.SmtpClientCommunicationException('550 User unknown'),
      );
      expect(failure, isA<MailServerRefused>());
      expect(failure.reason, contains('550 User unknown'));
    });

    test('mappe SocketException en MailConnectionFailed', () {
      final failure = SmtpMailTransport.mapException(
        const SocketException('Failed host lookup: smtp.gmail.com'),
      );
      expect(failure, isA<MailConnectionFailed>());
    });

    test('mappe SmtpNoGreetingException en MailConnectionFailed', () {
      final failure = SmtpMailTransport.mapException(
        mailer.SmtpNoGreetingException('No greeting from server'),
      );
      expect(failure, isA<MailConnectionFailed>());
    });
  });
}
