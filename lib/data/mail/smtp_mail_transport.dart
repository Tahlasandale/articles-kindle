import 'dart:async';
import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

import 'mail_transport.dart';

/// Envoi réel par SMTP, via `mailer`.
///
/// Jamais utilisé dans un test : les tests passent par un faux transport, pour
/// qu'aucun mot de passe ne sorte de la machine et qu'aucun message ne parte
/// vraiment.
class SmtpMailTransport implements MailTransport {
  SmtpMailTransport({
    required this.host,
    required this.port,
    required this.username,
    this.password,
    this.passwordProvider,
    required this.useTls,
  }) : assert(
         password != null || passwordProvider != null,
         'Fournissez un mot de passe ou un passwordProvider.',
       );

  final String host;
  final int port;
  final String username;
  final String? password;
  final Future<String?> Function()? passwordProvider;
  final bool useTls;

  Future<String?> resolvePassword() async {
    if (password != null && password!.isNotEmpty) return password;
    if (passwordProvider != null) return await passwordProvider!();
    return password;
  }

  static const Duration connectTimeout = Duration(seconds: 12);

  /// Mappe une exception brute SMTP en une [MailFailure] explicite.
  static MailFailure mapException(Object error) {
    if (error is MailFailure) return error;
    if (error is mailer.SmtpClientAuthenticationException) {
      return const MailAuthenticationFailed();
    }
    if (error is mailer.SmtpUnsecureException) {
      return const MailConfigurationIncomplete(
        'Le serveur refuse une connexion non chiffrée.',
      );
    }
    if (error is mailer.SmtpMessageValidationException) {
      final details = error.problems.map((p) => p.msg).join(', ');
      return MailConfigurationIncomplete(
        'Adresse ou message invalide : $details',
      );
    }
    if (error is mailer.SmtpClientCommunicationException) {
      final msg = error.message;
      if (msg.contains('535') ||
          msg.toLowerCase().contains('authentication') ||
          msg.toLowerCase().contains('credential')) {
        return const MailAuthenticationFailed();
      }
      return MailServerRefused(msg);
    }
    if (error is SocketException) {
      final detail = error.osError?.message ?? error.message;
      return MailConnectionFailed(
        detail.isNotEmpty ? detail : error.toString(),
      );
    }
    if (error is TimeoutException) {
      return const MailConnectionFailed('Délai d\'attente dépassé (timeout)');
    }
    if (error is HandshakeException) {
      return const MailConnectionFailed('Échec de négociation TLS/SSL');
    }
    if (error is mailer.SmtpNoGreetingException) {
      return const MailConnectionFailed('Le serveur n\'a pas répondu à temps');
    }
    final str = error.toString();
    if (str.contains('535') || str.toLowerCase().contains('auth')) {
      return const MailAuthenticationFailed();
    }
    return MailConnectionFailed(str);
  }

  @override
  Future<void> send(OutgoingMessage message) async {
    // Pas de chiffrement, pas d'envoi : le mot de passe ne partirait pas en
    // clair. C'est une décision, pas une erreur à rattraper plus tard.
    if (!useTls) {
      throw const MailConfigurationIncomplete(
        'Le chiffrement est obligatoire pour envoyer le mot de passe.',
      );
    }

    final rawPassword = await resolvePassword() ?? '';
    final cleanPassword = rawPassword.trim().replaceAll(' ', '');
    if (cleanPassword.isEmpty) {
      throw const MailAuthenticationFailed();
    }

    final cleanHost = host.trim();
    final cleanUsername = username.trim();
    final cleanFrom = message.from.trim();
    final cleanTo = message.to.trim();

    final primaryServer = SmtpServer(
      cleanHost,
      port: port,
      username: cleanUsername,
      password: cleanPassword,
      ssl: port == 465,
      allowInsecure: false,
    );

    final directories = <Directory>[];

    final mail = mailer.Message()
      ..from = cleanFrom
      ..recipients = [cleanTo]
      ..subject = message.subject
      ..text = message.text.isEmpty ? ' ' : message.text
      ..attachments = [
        for (final attachment in message.attachments)
          mailer.FileAttachment(
            _writeTemporary(attachment, directories),
            fileName: attachment.fileName,
          ),
      ];

    try {
      try {
        await mailer.send(mail, primaryServer, timeout: connectTimeout);
      } catch (primaryError) {
        // En cas d'échec de connexion (souvent port 587 bloqué par les opérateurs mobiles 4G/5G),
        // tenter automatiquement le port alternatif sécurisé (465 SSL ou 587 STARTTLS).
        final isConnectionIssue =
            primaryError is SocketException ||
            primaryError is TimeoutException ||
            primaryError is mailer.SmtpNoGreetingException ||
            primaryError is HandshakeException;

        if (isConnectionIssue && (port == 587 || port == 465)) {
          final fallbackPort = port == 587 ? 465 : 587;
          final fallbackServer = SmtpServer(
            cleanHost,
            port: fallbackPort,
            username: cleanUsername,
            password: cleanPassword,
            ssl: fallbackPort == 465,
            allowInsecure: false,
          );
          try {
            await mailer.send(mail, fallbackServer, timeout: connectTimeout);
            return;
          } catch (_) {
            throw mapException(primaryError);
          }
        }
        throw mapException(primaryError);
      }
    } finally {
      for (final directory in directories) {
        if (directory.existsSync()) directory.deleteSync(recursive: true);
      }
    }
  }

  /// `FileAttachment` lit un fichier : on écrit la pièce jointe dans un
  /// répertoire temporaire, puis on le supprime après l'envoi.
  File _writeTemporary(MailAttachment attachment, List<Directory> created) {
    final directory = Directory.systemTemp.createTempSync('kindle-attach');
    created.add(directory);
    final file = File('${directory.path}/${attachment.fileName}')
      ..writeAsBytesSync(attachment.bytes);
    return file;
  }
}
