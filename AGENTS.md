# AGENTS.md

Instructions pour un agent qui travaille dans ce dépôt. Elles complètent
`README.md` (installation et usage), `DECISIONS.md` (pourquoi) et
`docs/design-doc.md` (quoi). Ce fichier ne contient que ce qu'on ne peut pas déduire
du code : **les portes à passer, les pièges déjà payés, et les conventions.**

## 1. Le dépôt

Application Flutter **Android uniquement** (`flutter create --platforms=android`), sans
serveur, sans compte, sans télémétrie. Elle transforme des articles web en EPUB et
l'envoie à une Kindle par SMTP.

Invariants, à ne pas casser :

- **Aucun test ne touche le réseau.** Le réseau passe par `ArticleFetcher`, le SMTP par
  `MailTransport`. Les deux sont injectés etAlways remplacés par un faux en test.
- **Aucun service tiers.** `curl.md` sert d'oracle en développement
  (`docs/CURL.md`), jamais dans l'application.
- **Le mot de passe SMTP vit dans le Keystore**, jamais en base, jamais journalisé.
- **Le HTML extrait part vers Amazon**, pas vers un WebView : scripts et attributs
  d'événements sont retirés à l'extraction.

## 2. Les portes

Rien n'est poussé avec une porte rouge. Tout depuis la racine du dépôt :

```bash
flutter analyze                 # doit sortir vide
flutter test                    # cœur : URL, flux, extraction, EPUB, base, SMTP
dart run build_runner build --delete-conflicting-outputs   # code Drift à jour
tool/epubcheck.sh               # valide chaque EPUB généré par les tests
```

`tool/epubcheck.sh` télécharge `epubcheck.jar` dans `tool/cache/` au premier lancement et
a besoin d'un **JDK** dans le `PATH` (`JAVA_HOME`). Si le JDK manque, le script s'arrête
avec un message explicite plutôt que de laisser passer l'EPUB.

Avant de pousser : `git status` doit être propre et `dart format --output=none --set-exit-if-changed lib test`
doit sortir 0.

## 3. Deux toolchains, une seule dans le `PATH`

Cette machine n'a **pas de JDK système** : le JDK 17 portable est dans `~/dev/jdk17`.
Sans cela, Gradle et `epubcheck` échouent avec des messages trompeurs.

```bash
export PATH="$HOME/dev/flutter/bin:$PATH"
export JAVA_HOME="$HOME/dev/jdk17"
export ANDROID_HOME="$HOME/Android/Sdk"
```

**Vérifie `flutter doctor` avant de conclure qu'un problème vient du code.**

## 4. TDD sur le cœur

Le test s'écrit **avant** l'implémentation pour tout ce qui est testable sans écran :
normalisation d'URL, parsing de flux, extraction, EPUB, Drift, `KindleMailer`. L'UI est
écrite d'abord, couverte ensuite.

Le corpus de fixtures est dans `test/fixtures/html/` : des pages réelles figées, scripts
et trackers retirés. **Ne pas versionner de page entière avec ses scripts de suivi**, et
ne pas ajouter de fixture qui n'a pas.failé au moins une fois.

## 5. Conventions

- Interface, README et messages d'erreur en français ; code, identifiants et
  commentaires en anglais ; commits `type(scope): sujet français`.
- Le design system est dans `lib/ui/theme/` : aucune couleur, aucun rayon et aucune
  bordure écrite en dur dans un écran. Noir et blanc, coins carrés, liseré de 1 px.
- Les statuts sont signalés par **un mot et un symbole**, jamais par la couleur : l'app
  est monochrome.
- Tout traitement lourd (extraction, EPUB, images) passe par un isolate.

## 6. Pièges déjà payés

- **`sqlite3_flutter_libs` est mort.** Ne l'ajoute pas, même si un tutoriel le demande :
  la version `0.6.0+eol` existe pour annoncer la fin du paquet. Les bibliothèques
  natives viennent de `sqlite3` 3.x et ses build hooks.
- **`webfeed_plus` est figé depuis 2024** et ne gère pas ETag / If-Modified-Since. Le
  parsing de flux est écrit dans `lib/data/feeds/`.
- **Aucun paquet Dart de génération EPUB 3 n'est fiable.** L'EPUB est produit à la main
  dans `lib/data/epub/`. Le piège OCF : `mimetype` doit être la **première entrée** du ZIP
  et **non compressée** (`ZipEncoder` avec `level: Store` sur cette entrée).
- **Kindle 7e génération** : n'embarquez pas de police dans l'EPUB, Amazon la supprime.
  Serif système dans le livre, Libron seulement dans l'app.
- **`receive_sharing_intent`** exige `android:launchMode="singleTask"` et un
  `intent-filter` `SEND` dans le Manifest, sinon le partage ouvre une seconde instance.
  Le plugin compile aussi avec `compileSdk 37`, que le SDK Manager ne publie plus sous
  ce nom : il installe `platforms/android-37.0` et Gradle échoue alors sur
  `Failed to find target with hash string 'android-37'`. Contournement sur cette machine :
  `ln -sfn ~/Android/Sdk/platforms/android-37.0 ~/Android/Sdk/platforms/android-37`.
  C'est le problème de build le plus signalé du plugin — s'il réapparaît, ce n'est pas
  notre code.
- **Amazon ignore silencieusement** tout message dont l'expéditeur n'est pas dans la
  liste des expéditeurs autorisés du compte : aucun SMTP ne signale l'erreur. D'où le
  bouton « Tester l'envoi » qui n'allume rien en cas de succès.