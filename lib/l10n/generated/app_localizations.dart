import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Articles vers Kindle'**
  String get appTitle;

  /// No description provided for @tabToRead.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get tabToRead;

  /// No description provided for @tabSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get tabSend;

  /// No description provided for @tabHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get tabSettings;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get statusReady;

  /// No description provided for @statusFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get statusFailed;

  /// No description provided for @statusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get statusSent;

  /// No description provided for @toReadEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article'**
  String get toReadEmptyTitle;

  /// No description provided for @toReadEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Partagez un article depuis votre navigateur, ou ajoutez son adresse.'**
  String get toReadEmptyBody;

  /// No description provided for @toReadAddUrl.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get toReadAddUrl;

  /// No description provided for @toReadAddSite.
  ///
  /// In fr, this message translates to:
  /// **'Articles d\'un site'**
  String get toReadAddSite;

  /// No description provided for @toReadSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un article'**
  String get toReadSearchHint;

  /// No description provided for @toReadSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article ne correspond.'**
  String get toReadSearchEmpty;

  /// No description provided for @toReadRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get toReadRetry;

  /// No description provided for @toReadOpenInBrowser.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans le navigateur'**
  String get toReadOpenInBrowser;

  /// No description provided for @toReadDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get toReadDelete;

  /// No description provided for @toReadSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun sélectionné} =1{1 article sélectionné} other{{count} articles sélectionnés}}'**
  String toReadSelectedCount(int count);

  /// No description provided for @addUrlTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get addUrlTitle;

  /// No description provided for @addUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de l\'article'**
  String get addUrlHint;

  /// No description provided for @addUrlPaste.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get addUrlPaste;

  /// No description provided for @addUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse n\'est pas valide.'**
  String get addUrlInvalid;

  /// No description provided for @addUrlDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Cet article est déjà dans la liste.'**
  String get addUrlDuplicate;

  /// No description provided for @addUrlAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addUrlAdd;

  /// No description provided for @addSiteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Articles d\'un site'**
  String get addSiteTitle;

  /// No description provided for @addSiteHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du site ou du blog'**
  String get addSiteHint;

  /// No description provided for @addSiteSearch.
  ///
  /// In fr, this message translates to:
  /// **'Chercher les articles'**
  String get addSiteSearch;

  /// No description provided for @addSiteNoFeed.
  ///
  /// In fr, this message translates to:
  /// **'Aucun flux d\'articles n\'a été trouvé sur cette page.'**
  String get addSiteNoFeed;

  /// No description provided for @addSiteSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout cocher'**
  String get addSiteSelectAll;

  /// No description provided for @addSiteSelectNone.
  ///
  /// In fr, this message translates to:
  /// **'Tout décocher'**
  String get addSiteSelectNone;

  /// No description provided for @addSiteAddSelected.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter les articles cochés'**
  String get addSiteAddSelected;

  /// No description provided for @addSiteFinding.
  ///
  /// In fr, this message translates to:
  /// **'Recherche des articles…'**
  String get addSiteFinding;

  /// No description provided for @addSiteEmptyFeed.
  ///
  /// In fr, this message translates to:
  /// **'Ce flux ne contient aucun article.'**
  String get addSiteEmptyFeed;

  /// No description provided for @addSiteTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Les {count} derniers articles sont proposés.'**
  String addSiteTooMany(int count);

  /// No description provided for @sendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à la Kindle'**
  String get sendTitle;

  /// No description provided for @sendSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count} article(s) — environ {size}'**
  String sendSummary(int count, String size);

  /// No description provided for @sendNothing.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article à envoyer. Ajoutez au moins un article prêt.'**
  String get sendNothing;

  /// No description provided for @sendButton.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à la Kindle'**
  String get sendButton;

  /// No description provided for @sendStepExtract.
  ///
  /// In fr, this message translates to:
  /// **'Préparation des articles'**
  String get sendStepExtract;

  /// No description provided for @sendStepBuild.
  ///
  /// In fr, this message translates to:
  /// **'Génération du livre'**
  String get sendStepBuild;

  /// No description provided for @sendStepMail.
  ///
  /// In fr, this message translates to:
  /// **'Envoi par e-mail'**
  String get sendStepMail;

  /// No description provided for @sendSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Livre envoyé. Amazon le convertit pour votre Kindle.'**
  String get sendSuccess;

  /// No description provided for @sendTooLargeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livre trop lourd'**
  String get sendTooLargeTitle;

  /// No description provided for @sendTooLargeBody.
  ///
  /// In fr, this message translates to:
  /// **'Le livre pèse environ {size}. Amazon refuse les pièces jointes de plus de 50 Mo. Retirez des articles, ou désactivez les images dans les Réglages.'**
  String sendTooLargeBody(String size);

  /// No description provided for @sendTestButton.
  ///
  /// In fr, this message translates to:
  /// **'Tester l\'envoi'**
  String get sendTestButton;

  /// No description provided for @sendTestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Test d\'envoi'**
  String get sendTestTitle;

  /// No description provided for @sendTestSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Message de test accepté par le serveur.'**
  String get sendTestSuccess;

  /// No description provided for @sendReorderHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser pour changer l\'ordre des chapitres.'**
  String get sendReorderHint;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun envoi pour l\'instant.'**
  String get historyEmpty;

  /// No description provided for @historySentOn.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé le {date} — {count} article(s), {size}'**
  String historySentOn(String date, int count, String size);

  /// No description provided for @historyFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec le {date} — {error}'**
  String historyFailed(String date, String error);

  /// No description provided for @historyQueuedAgain.
  ///
  /// In fr, this message translates to:
  /// **'Remis dans la file'**
  String get historyQueuedAgain;

  /// No description provided for @historyQueuedAgainAction.
  ///
  /// In fr, this message translates to:
  /// **'Remettre dans la file'**
  String get historyQueuedAgainAction;

  /// No description provided for @historyPurge.
  ///
  /// In fr, this message translates to:
  /// **'Purger les articles envoyés'**
  String get historyPurge;

  /// No description provided for @historyPurgeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le contenu des {count} articles déjà envoyés ? Les titres et les liens sont conservés.'**
  String historyPurgeConfirm(int count);

  /// No description provided for @settingsKindleSection.
  ///
  /// In fr, this message translates to:
  /// **'Kindle'**
  String get settingsKindleSection;

  /// No description provided for @settingsKindleAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse Kindle'**
  String get settingsKindleAddress;

  /// No description provided for @settingsKindleAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'nom@kindle.com'**
  String get settingsKindleAddressHint;

  /// No description provided for @settingsBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du livre'**
  String get settingsBookTitle;

  /// No description provided for @settingsBookTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour « Lectures du JJ/MM/AAAA »'**
  String get settingsBookTitleHint;

  /// No description provided for @settingsSmtpSection.
  ///
  /// In fr, this message translates to:
  /// **'Envoi'**
  String get settingsSmtpSection;

  /// No description provided for @settingsSmtpHost.
  ///
  /// In fr, this message translates to:
  /// **'Serveur SMTP'**
  String get settingsSmtpHost;

  /// No description provided for @settingsSmtpPort.
  ///
  /// In fr, this message translates to:
  /// **'Port'**
  String get settingsSmtpPort;

  /// No description provided for @settingsSmtpUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get settingsSmtpUsername;

  /// No description provided for @settingsSmtpPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe d\'application'**
  String get settingsSmtpPassword;

  /// No description provided for @settingsSmtpSender.
  ///
  /// In fr, this message translates to:
  /// **'Adresse expéditeur'**
  String get settingsSmtpSender;

  /// No description provided for @settingsSmtpSenderHint.
  ///
  /// In fr, this message translates to:
  /// **'Doit figurer dans les expéditeurs autorisés Amazon'**
  String get settingsSmtpSenderHint;

  /// No description provided for @settingsSmtpTls.
  ///
  /// In fr, this message translates to:
  /// **'Chiffrement STARTTLS'**
  String get settingsSmtpTls;

  /// No description provided for @settingsSmtpTlsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le chiffrement est obligatoire : un envoi en clair est refusé.'**
  String get settingsSmtpTlsRequired;

  /// No description provided for @settingsEpubSection.
  ///
  /// In fr, this message translates to:
  /// **'Livre'**
  String get settingsEpubSection;

  /// No description provided for @settingsEpubImages.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les images'**
  String get settingsEpubImages;

  /// No description provided for @settingsEpubGrayscale.
  ///
  /// In fr, this message translates to:
  /// **'Images en niveaux de gris'**
  String get settingsEpubGrayscale;

  /// No description provided for @settingsEpubImageWidth.
  ///
  /// In fr, this message translates to:
  /// **'Largeur max des images'**
  String get settingsEpubImageWidth;

  /// No description provided for @settingsEpubSizeLimit.
  ///
  /// In fr, this message translates to:
  /// **'Taille max avant alerte'**
  String get settingsEpubSizeLimit;

  /// No description provided for @settingsEpubTestHint.
  ///
  /// In fr, this message translates to:
  /// **'Amazon peut mettre quelques minutes à convertir le livre.'**
  String get settingsEpubTestHint;

  /// No description provided for @settingsThemeSection.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsThemeSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsDataSection.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsDataSection;

  /// No description provided for @settingsPurge.
  ///
  /// In fr, this message translates to:
  /// **'Purger les articles envoyés'**
  String get settingsPurge;

  /// No description provided for @themeToggleTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Changer de thème'**
  String get themeToggleTooltip;

  /// No description provided for @tagAdd.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get tagAdd;

  /// No description provided for @tagAddHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'étiquette'**
  String get tagAddHint;

  /// No description provided for @tagRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'étiquette'**
  String get tagRemove;

  /// No description provided for @tagFilterNone.
  ///
  /// In fr, this message translates to:
  /// **'Sans étiquette'**
  String get tagFilterNone;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Réessayez une fois le réseau revenu.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le site n\'a pas répondu à temps.'**
  String get errorTimeout;

  /// No description provided for @errorHttpStatus.
  ///
  /// In fr, this message translates to:
  /// **'Le site a répondu {status}.'**
  String errorHttpStatus(int status);

  /// No description provided for @errorNoContent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contenu exploitable n\'a été trouvé sur cette page.'**
  String get errorNoContent;

  /// No description provided for @errorTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Cette page est trop lourde pour être téléchargée.'**
  String get errorTooLarge;

  /// No description provided for @errorAuth.
  ///
  /// In fr, this message translates to:
  /// **'Authentification refusée. Vérifiez le mot de passe d\'application.'**
  String get errorAuth;

  /// No description provided for @errorSmtpSend.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur SMTP a refusé le message : {error}'**
  String errorSmtpSend(String error);

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'Ok'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
