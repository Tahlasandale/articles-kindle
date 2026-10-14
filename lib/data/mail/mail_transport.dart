/// Pièce jointe d'un message d'envoi.
class MailAttachment {
  const MailAttachment({
    required this.fileName,
    required this.bytes,
    this.mimeType = 'application/epub+zip',
  });

  final String fileName;
  final List<int> bytes;
  final String mimeType;
}

/// Message prêt à partir.
///
/// Amazon ignore le sujet et le corps : seul le nom du fichier compte, il devient
/// le titre du livre. Le champ `text` existe pour que le message reste valide si
/// le destinataire l'ouvre dans un logiciel de courrier.
class OutgoingMessage {
  const OutgoingMessage({
    required this.from,
    required this.to,
    this.subject = '',
    this.text = '',
    this.attachments = const [],
  });

  final String from;
  final String to;
  final String subject;
  final String text;
  final List<MailAttachment> attachments;
}

/// Point d'entrée SMTP. L'application ne connaît que cette interface : les tests
/// n'envoient jamais de vrai courrier.
abstract class MailTransport {
  Future<void> send(OutgoingMessage message);
}

/// Ce qui a pu empêcher un envoi.
sealed class MailFailure implements Exception {
  const MailFailure();

  /// Message affichable, sans jargon SMTP.
  String get reason;
}

class MailAuthenticationFailed extends MailFailure {
  const MailAuthenticationFailed();
  @override
  String get reason =>
      'Authentification refusée. Vérifiez le mot de passe d\'application.';
}

class MailConnectionFailed extends MailFailure {
  const MailConnectionFailed([this.detail]);

  final String? detail;

  @override
  String get reason => detail != null && detail!.isNotEmpty
      ? 'Connexion au serveur impossible ($detail). Vérifiez le réseau ou le port.'
      : 'Connexion au serveur impossible. Vérifiez le réseau ou le port.';
}

class MailServerRefused extends MailFailure {
  const MailServerRefused(this.detail);
  final String detail;
  @override
  String get reason => 'Le serveur SMTP a refusé le message : $detail';
}

class MailAttachmentTooLarge extends MailFailure {
  const MailAttachmentTooLarge(this.sizeBytes);
  final int sizeBytes;
  @override
  String get reason =>
      'Le livre pèse ${(sizeBytes / 1000000).toStringAsFixed(1)} Mo. '
      'Amazon refuse les pièces jointes de plus de 50 Mo.';
}

class MailConfigurationIncomplete extends MailFailure {
  const MailConfigurationIncomplete(this.reason);
  @override
  final String reason;
}
