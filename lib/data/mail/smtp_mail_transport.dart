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
    if (error is mailer.SmtpClientCommunicationException) {
      final msg = error.message;
      if (msg.contains('535') ||
          msg.toLowerCase().contains('authentication') ||
          msg.toLowerCase().contains('credential')) {
        return const MailAuthenticationFailed();
      }
      return MailServerRefused(msg);
    }
    if (error is mailer.SmtpNoGreetingException ||
        error is SocketException ||
        error is TimeoutException ||
        error is HandshakeException) {
      return const MailConnectionFailed();
    }
    final str = error.toString();
    if (str.contains('535') || str.toLowerCase().contains('auth')) {
      return const MailAuthenticationFailed();
    }
    return const MailConnectionFailed();
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

    final resolvedPassword = await resolvePassword() ?? '';
    if (resolvedPassword.isEmpty) {
      throw const MailAuthenticationFailed();
    }

    final server = SmtpServer(
      host,
      port: port,
      username: username,
      password: resolvedPassword,
      ssl: port == 465,
      allowInsecure: false,
    );

    final directories = <Directory>[];

    final mail = mailer.Message()
      ..from = message.from
      ..recipients = [message.to]
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
      // En mailer 7, un retour sans exception signifie que le serveur a accepté
      // le message : le refus remonte en `SmtpClientCommunicationException`.
      await mailer.send(mail, server);
    } catch (error) {
      throw mapException(error);
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
