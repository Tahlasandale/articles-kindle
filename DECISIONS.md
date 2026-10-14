# DECISIONS

Journal des décisions techniques et des écarts assumés par rapport à
`docs/design-doc.md`. Chaque ligne est écrite **au moment où la décision est prise**,
pas reconstruite après coup.

Convention de commit : préfixe de type en anglais (`feat:`, `fix:`, `test:`), sujet
en français.

---

## Les liens entrent, les flux ne sont pas une fonctionnalité

- **Décision** : l'application ne gère ni abonnement ni rafraîchissement de flux. Un
  article entre par le menu Partager Android, par saisie d'URL, ou par « articles du
  site ».
- **Pourquoi** : l'usage réel est « je balance des liens d'article ». Un lecteur de flux
  est une deuxième application, avec ses propres états (lu/non lu, filtres, Retention),
  qui n'apporte rien au cycle `lien → EPUB → Kindle`.
- **Écart** : spec §3.2 (F6–F8), §7.3, §11 onglet « Flux », jalon M5.

## Le flux sert d'index, quand on le demande explicitement

- **Décision** : « articles du site » cherche le `<link rel="alternate">` de la page,
  télécharge le flux, et propose les éléments **à cocher**. Rien n'est ajouté d'office.
  Si l'élément porte `content:encoded`, ce texte est utilisé sans télécharger la page.
- **Pourquoi** : c'est la façon la plus fiable de lister les articles d'un site sans
  réécrire un détecteur de pages de listing, et ça ne coûte rien quand on ne le demande
  pas.
- **Écart** : ce n'est pas un abonnement : pas de `table feeds` dans le schéma.

## Pas de port de Readability

- **Décision** : l'extraction repose sur un score de densité écrit pour ce projet
  (texte par nœud, balises sémantiques, ratio de liens, classes et attributs bruyants).
- **Pourquoi** : `readability_port` n'existe pas, `readability` (SphericalKat) est
  abandoned et son dépôt a disparu, `reader_mode` a un like, `html_readability` est une
  réimplémentation de 2 fichiers. Aucune dépendance à maintenir, et un score adapté au
  web francophone et aux blogs auto-hébergés.
- **Écart** : spec §6 « Port Dart de Readability ».

## Le générateur d'EPUB est écrit ici

- **Décision** : EPUB 3 produit à la main sur `archive` (`ZipEncoder`), avec
  `mimetype` non compressé en première entrée, `container.xml`, `content.opf`,
  `nav.xhtml`, `toc.ncx`, un XHTML par chapitre et une feuille de style e-ink.
- **Pourquoi** : il n'existe pas de paquet Dart de génération EPUB 3 fiable.
  `epub` est un parseur Dart 2, `epub_builder` a 0 like et 130/160 points, `epub3`
  dépend d'`archive` 3.x et d'`image` 3.x. Chaque fichier généré passe `epubcheck`.
- **Écart** : spec §6 « ZIP / EPUB : archive » (l'intention tenait, le paquet listed
  n'existait pas).

## `sqlite3_flutter_libs` est mort, on ne l'ajoute pas

- **Décision** : `drift` 2.35 + `sqlite3` 3.x, sans `sqlite3_flutter_libs`. Les
  bibliothèques natives sont bundlées par les build hooks de `sqlite3`.
- **Pourquoi** : la version `0.6.0+eol` est publiée pour annoncer la fin du paquet, et
  le changelog de drift 2.32 impose le passage à `sqlite3` 3.x. Tout tutoriel qui
  mentionne `sqlite3_flutter_libs` est périmé.
- **Écart** : spec §6 « Base locale : drift + sqlite3_flutter_libs ».

## Parsing de flux écrit sur `xml`

- **Décision** : parsing RSS 2.0 / Atom écrit sur le paquet `xml`, sans
  `webfeed_plus`.
- **Pourquoi** : `webfeed_plus` est figé depuis juillet 2024, n'est pas revalidé
  (ETag, If-Modified-Since) et contraint `intl ^0.19` face au `intl 0.20+` des versions
  récentes de Flutter. Le format du flux tient en deux cents lignes de parsing.

## Gmail par défaut, STARTTLS obligatoire, aucun envoi réel en test

- **Décision** : préréglages `smtp.gmail.com:587`, mot de passe d'application dans le
  Keystore via `flutter_secure_storage`, `allowInsecure` jamais activé. Le
  `KindleMailer` reçoit un `MailTransport` injectable ; les tests utilisent un faux
  transport en mémoire.
- **Pourquoi** : un test d'intégration qui part sur le vrai Gmail exige un secret et
  envoie du courrier réel. La spec §14 prévoyait MailHog, ce n'est plus nécessaire.
- **Écart** : spec §14 « intégration : serveur SMTP local ».

## `dio` derrière une interface, jamais en test

- **Décision** : `ArticleFetcher` est une interface Dart ; l'implémentation réelle
  utilise `dio` (timeouts, User-Agent, redirections, taille maximale, deux requêtes
  simultanées par domaine), les tests fournissent des réponses enregistrées.
- **Pourquoi** : aucun test ne doit toucher le réseau, et l'extracteur doit pouvoir
  être comparé à curl.md sur les mêmes entrées.

## On garde le contenu des articles envoyés

- **Décision** : après envoi, `content_html` reste en base. Purge manuelle depuis les
  Réglages **et** depuis l'Historique.
- **Pourquoi** : l'historique reste consultable hors ligne et « remettre dans la file »
  redevient possible. Le coût est une base qui grossit, d'où la purge.
- **Écart** : question ouverte §18.4.

## Au-delà de 25 Mo, l'app alerte et vous décidez

- **Décision** : l'app mesure la taille estimée avant l'envoi et refuse d'envoyer
  au-delà du seuil en proposant de retirer des articles ou de désactiver les images. Pas
  de découpe automatique.
- **Pourquoi** : Amazon accepte 50 Mo par e-mail ; la découpe automatique produit des
  livres qu'on ne lit pas jusqu'au bout et没有一个 instant où l'utilisateur voit le
  résultat.
- **Écart** : spec §8 « découpe automatique », F14.

## Android seul en v1

- **Décision** : `flutter create --platforms=android`. iOS plus tard.
- **Pourquoi** : le partage entrant (jalon M4) et le test sur Kindle 7e génération se
  font sans Mac ni provisioning Apple. Le Share Extension iOS demande de toute façon un
  App Group et du code natif.
- **Écart** : question ouverte §18.1.

## Design system : e-ink brutaliste, monochrome

- **Décision** : palette noir et blanc purs (mode sombre : les valeurs inversées), coins
  carrés, liseré de 1 px, aucune ombre, Libron dans toute l'interface, statut porté par
  un mot et un symbole, jamais par la couleur. Thème à trois états (clair, sombre,
  système) avec un bouton dans la barre supérieure.
- **Pourquoi** : l'app sert à préparer des livres pour un écran e-ink. L'interface
  adoptait le même registre, et une palette monochrome supprime tout problème de
  contraste à maintenir.

## Libron dans l'app, serif système dans le livre

- **Décision** : Libron (OFL, `nicoverbruggen/libron`) est embarquée dans l'app. Le
  CSS de l'EPUB déclare `Georgia, 'Times New Roman', serif` sans police embarquée.
- **Pourquoi** : le Kindle 7e génération à firmware récent ne conserve pas les polices
  embarquées d'un EPUB envoyé par Send-to-Kindle — Amazon les remplace. L'embarquer
  coûterait plusieurs centaines de kilo-octets pour un rendu non garanti.

## Un seul mécanisme de persistance des réglages

- **Décision** : les réglages non sensibles (adresse Kindle, options d'EPUB, thème) sont
  dans une table `settings` en Drift. Seul le mot de passe SMTP vit dans le Keystore.
- **Pourquoi** : un seul jeu de migrations à écrire et à tester, contre deux mécanismes
  pour `shared_preferences`.

## Ordre des chapitres laissé libre

- **Décision** : réordonnable à la main par glisser-déposer dans l'écran d'envoi.
- **Pourquoi** : l'ordre d'ajout est un hasard d'usage, pas une intention de lecture.

## Pas d'appareil Android pendant le développement

- **Décision** : les APK sont construits et livrés signés avec le certificat de
  débogage. Aucune configuration de signature n'est versionnée.
- **Pourquoi** : cet APK est destiné à être installé sur le téléphone du
  propriétaire, pas publié. Un keystor versionné dans un dépôt public est un
  problème ; un keystor local jamais écrit est simplement inutilisable.
- **Écart** : aucune publication possible en l'état. Le jour où la publication
 -decide, il faut créer le keystor, le garder hors du dépôt, et configurer
  `key.properties` (voir le documentation Flutter sur la signature Android).

- **Décision** : la livraison de ce lot s'arrête à un APK debug compilé, accompagné
  d'une checklist de gestes à faire sur le téléphone. Aucun test d'intégration du
  partage.
- **Pourquoi** : il n'y a pas d'appareil Android branché à cette machine.

## `compileSdk 37`, et le lien symbolique qu'il faut faire une fois

- **Décision** : `android/app/build.gradle.kts` fixe `compileSdk = 37`, et la machine
  de développement doit avoir `platforms/android-37` pointant sur
  `platforms/android-37.0`.
- **Pourquoi** : `receive_sharing_intent` 1.9 compile avec `compileSdk 37` et refuse
  de compiler contre 36. Or le SDK Manager ne publie plus de plateforme `android-37` :
  seulement `android-37.0`, sous un nom que Gradle ne reconnaît pas
  (`Failed to find target with hash string 'android-37'`). C'est le problème de build
  le plus signalé du plugin — 218 issues ouvertes sur 378 étoiles.
- **Écart** : AGP 9.1 recommande un `compileSdk` de 36 au maximum ; on accepte son
  avertissement. Un jour, `flutter.compileSdkVersion` suffira de nouveau : c'est à
  vérifier à chaque montée de version du plugin, pas une configuration à respecter
  aveuglément.

## Aucun keystore pour l'instant

- **Décision** : les APK sont livrés signés avec le certificat de débogage. Aucune
  configuration de signature n'est versionnée.
- **Pourquoi** : cet APK est destiné au téléphone de son propriétaire, pas au Play
  Store. Un keystor versionné dans un dépôt public est un problème ; un keystor
  local jamais écrit est seulement inutilisable.
- **Écart** : aucune publication en l'état. Le jour où la publication se décide, il
  faut créer la clé, la garder hors du dépôt, et brancher `key.properties` sur la
  signature Android de Gradle. Changer de clé impose ensuite une désinstallation
  avant toute mise à jour.
