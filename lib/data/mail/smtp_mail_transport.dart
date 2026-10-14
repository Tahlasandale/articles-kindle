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
    required this.password,
    required this.useTls,
  });

  final String host;
  final int port;
  final String username;
  final String password;
  final bool useTls;

  @override
  Future<void> send(OutgoingMessage message) async {
    // Pas de chiffrement, pas d'envoi : le mot de passe ne partirait pas en
    // clair. C'est une décision, pas une erreur à rattraper plus tard.
    if (!useTls) {
      throw const MailConfigurationIncomplete(
        'Le chiffrement est obligatoire pour envoyer le mot de passe.',
      );
    }

    final server = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
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
    } on mailer.SmtpClientAuthenticationException {
      throw const MailAuthenticationFailed();
    } on mailer.SmtpUnsecureException {
      throw const MailConfigurationIncomplete(
        'Le serveur refuse une connexion non chiffrée.',
      );
    } on MailFailure {
      rethrow;
    } catch (error) {
      throw const MailConnectionFailed();
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
