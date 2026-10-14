// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Articles vers Kindle';

  @override
  String get tabToRead => 'À lire';

  @override
  String get tabSend => 'Envoyer';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabSettings => 'Réglages';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusReady => 'Prêt';

  @override
  String get statusFailed => 'Échec';

  @override
  String get statusSent => 'Envoyé';

  @override
  String get toReadEmptyTitle => 'Aucun article';

  @override
  String get toReadEmptyBody =>
      'Partagez un article depuis votre navigateur, ou ajoutez son adresse.';

  @override
  String get toReadAddUrl => 'Ajouter une adresse';

  @override
  String get toReadAddSite => 'Articles d\'un site';

  @override
  String get toReadSearchHint => 'Rechercher un article';

  @override
  String get toReadSearchEmpty => 'Aucun article ne correspond.';

  @override
  String get toReadRetry => 'Réessayer';

  @override
  String get toReadOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get toReadDelete => 'Supprimer';

  @override
  String toReadSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles sélectionnés',
      one: '1 article sélectionné',
      zero: 'Aucun sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get addUrlTitle => 'Ajouter une adresse';

  @override
  String get addUrlHint => 'Adresse de l\'article';

  @override
  String get addUrlPaste => 'Coller';

  @override
  String get addUrlInvalid => 'Cette adresse n\'est pas valide.';

  @override
  String get addUrlDuplicate => 'Cet article est déjà dans la liste.';

  @override
  String get addUrlAdd => 'Ajouter';

  @override
  String get addSiteTitle => 'Articles d\'un site';

  @override
  String get addSiteHint => 'Adresse du site ou du blog';

  @override
  String get addSiteSearch => 'Chercher les articles';

  @override
  String get addSiteNoFeed =>
      'Aucun flux d\'articles n\'a été trouvé sur cette page.';

  @override
  String get addSiteSelectAll => 'Tout cocher';

  @override
  String get addSiteSelectNone => 'Tout décocher';

  @override
  String get addSiteAddSelected => 'Ajouter les articles cochés';

  @override
  String get addSiteFinding => 'Recherche des articles…';

  @override
  String get addSiteEmptyFeed => 'Ce flux ne contient aucun article.';

  @override
  String addSiteTooMany(int count) {
    return 'Les $count derniers articles sont proposés.';
  }

  @override
  String get sendTitle => 'Envoyer à la Kindle';

  @override
  String sendSummary(int count, String size) {
    return '$count article(s) — environ $size';
  }

  @override
  String get sendNothing =>
      'Aucun article à envoyer. Ajoutez au moins un article prêt.';

  @override
  String get sendButton => 'Envoyer à la Kindle';

  @override
  String get sendStepExtract => 'Préparation des articles';

  @override
  String get sendStepBuild => 'Génération du livre';

  @override
  String get sendStepMail => 'Envoi par e-mail';

  @override
  String get sendSuccess =>
      'Livre envoyé. Amazon le convertit pour votre Kindle.';

  @override
  String get sendTooLargeTitle => 'Livre trop lourd';

  @override
  String sendTooLargeBody(String size) {
    return 'Le livre pèse environ $size. Amazon refuse les pièces jointes de plus de 50 Mo. Retirez des articles, ou désactivez les images dans les Réglages.';
  }

  @override
  String get sendTestButton => 'Tester l\'envoi';

  @override
  String get sendTestTitle => 'Test d\'envoi';

  @override
  String get sendTestSuccess => 'Message de test accepté par le serveur.';

  @override
  String get sendReorderHint =>
      'Faites glisser pour changer l\'ordre des chapitres.';

  @override
  String get historyEmpty => 'Aucun envoi pour l\'instant.';

  @override
  String historySentOn(String date, int count, String size) {
    return 'Envoyé le $date — $count article(s), $size';
  }

  @override
  String historyFailed(String date, String error) {
    return 'Échec le $date — $error';
  }

  @override
  String get historyQueuedAgain => 'Remis dans la file';

  @override
  String get historyQueuedAgainAction => 'Remettre dans la file';

  @override
  String get historyPurge => 'Purger les articles envoyés';

  @override
  String historyPurgeConfirm(int count) {
    return 'Supprimer le contenu des $count articles déjà envoyés ? Les titres et les liens sont conservés.';
  }

  @override
  String get settingsKindleSection => 'Kindle';

  @override
  String get settingsKindleAddress => 'Adresse Kindle';

  @override
  String get settingsKindleAddressHint => 'nom@kindle.com';

  @override
  String get settingsBookTitle => 'Titre du livre';

  @override
  String get settingsBookTitleHint =>
      'Laisser vide pour « Lectures du JJ/MM/AAAA »';

  @override
  String get settingsSmtpSection => 'Envoi';

  @override
  String get settingsSmtpHost => 'Serveur SMTP';

  @override
  String get settingsSmtpPort => 'Port';

  @override
  String get settingsSmtpUsername => 'Identifiant';

  @override
  String get settingsSmtpPassword => 'Mot de passe d\'application';

  @override
  String get settingsSmtpSender => 'Adresse expéditeur';

  @override
  String get settingsSmtpSenderHint =>
      'Doit figurer dans les expéditeurs autorisés Amazon';

  @override
  String get settingsSmtpTls => 'Chiffrement STARTTLS';

  @override
  String get settingsSmtpTlsRequired =>
      'Le chiffrement est obligatoire : un envoi en clair est refusé.';

  @override
  String get settingsEpubSection => 'Livre';

  @override
  String get settingsEpubImages => 'Télécharger les images';

  @override
  String get settingsEpubGrayscale => 'Images en niveaux de gris';

  @override
  String get settingsEpubImageWidth => 'Largeur max des images';

  @override
  String get settingsEpubSizeLimit => 'Taille max avant alerte';

  @override
  String get settingsEpubTestHint =>
      'Amazon peut mettre quelques minutes à convertir le livre.';

  @override
  String get settingsThemeSection => 'Apparence';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsDataSection => 'Données';

  @override
  String get settingsPurge => 'Purger les articles envoyés';

  @override
  String get themeToggleTooltip => 'Changer de thème';

  @override
  String get tagAdd => 'Étiquette';

  @override
  String get tagAddHint => 'Nom de l\'étiquette';

  @override
  String get tagRemove => 'Retirer l\'étiquette';

  @override
  String get tagFilterNone => 'Sans étiquette';

  @override
  String get errorNetwork =>
      'Pas de connexion. Réessayez une fois le réseau revenu.';

  @override
  String get errorTimeout => 'Le site n\'a pas répondu à temps.';

  @override
  String errorHttpStatus(int status) {
    return 'Le site a répondu $status.';
  }

  @override
  String get errorNoContent =>
      'Aucun contenu exploitable n\'a été trouvé sur cette page.';

  @override
  String get errorTooLarge =>
      'Cette page est trop lourde pour être téléchargée.';

  @override
  String get errorAuth =>
      'Authentification refusée. Vérifiez le mot de passe d\'application.';

  @override
  String errorSmtpSend(String error) {
    return 'Le serveur SMTP a refusé le message : $error';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonClose => 'Fermer';
}
