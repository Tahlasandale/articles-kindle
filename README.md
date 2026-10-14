# Articles vers Kindle

> Vos liens, mis de côté, envoyés en un livre EPUB sur votre Kindle par e-mail. Tout
> reste sur votre téléphone : aucun serveur, aucun compte, aucune télémétrie.

Une application mobile **Flutter (Android)** qui transforme des articles web en un
livre EPUB et l'envoie à votre liseuse **Kindle 7e génération** à votre adresse
`@kindle.com`, par SMTP.

- **Entrées** : menu Partager du navigateur, saisie d'une URL, ou « articles du site »
  qui va chercher l'index des articles d'un blog.
- **Sortie** : un EPUB, un chapitre par article, une table des matières, envoyé par
  e-mail à l'adresse Amazon de votre Kindle.
- **Rien ne sort de l'appareil** : les articles sont téléchargés depuis les sites
  concernés et l'EPUB part vers le serveur SMTP que vous configurez. Aucun service
  tiers, aucun compte, aucune télémétrie.

## Essayer tout de suite

**[Version de test à télécharger](https://github.com/Tahlasandale/articles-kindle/releases/download/v0.1.0-test1/app-release.apk)**
— 67 Mo, Android 7 et plus récents. Téléchargez le fichier avec le navigateur du
téléphone, ouvrez-le, puis « Installer ». La recette complète est dans
[`docs/CHECKLIST-APPAREIL.md`](docs/CHECKLIST-APPAREIL.md).

**Documentation** : la spec complète est dans [`docs/design-doc.md`](docs/design-doc.md),
les écarts assumés et les choix de dépendance dans [`DECISIONS.md`](DECISIONS.md), les
portes à passer dans [`AGENTS.md`](AGENTS.md), la recette de validation sur votre
téléphone dans [`docs/CHECKLIST-APPAREIL.md`](docs/CHECKLIST-APPAREIL.md), le service
de comparaison utilisé en développement dans [`docs/CURL.md`](docs/CURL.md).

## État

Chaque jalon est commité et tagué :

| Jalon | Contenu | Tag |
|---|---|---|
| M1 Socle | base Drift, design system, quatre onglets, découverte de site | `v0.1-m1` |
| M2 Extraction | contenu lisible, score de densité, statuts, erreurs | `v0.1-m2` |
| M3 EPUB + envoi | générateur EPUB validé par epubcheck, envoi SMTP | `v0.1-m3` |
| M4 Partage | réception du menu Partager Android | `v0.1-m4` |

Reste à faire : la recette de [`docs/CHECKLIST-APPAREIL.md`](docs/CHECKLIST-APPAREIL.md),
sur votre téléphone.

## État vérifié à la livraison

- `flutter analyze` : aucun problème, aucune info.
- `flutter test` : **159 tests**, dont 33 fixtures HTML réelles balayées.
- `tool/epubcheck.sh` : epubcheck 5.4.0 valide les EPUB générés (1, 12 chapitres,
  accents et esperluettes).
- APK debug **et** release compilés ; le manifeste de l'APK a été dumpsé pour
  vérifier `singleTask`, les trois `intent-filter`, `allowBackup=false` et
  l'absence de permission superflue.

Non vérifié : tout ce qui demande un téléphone — partage réel, réception sur la
Kindle, rendu du livre. C'est ce que décrit la checklist.

## Installer la toolchain

```bash
# JDK 17 — Android Gradle Plugin et epubcheck en ont besoin
sudo apt install -y openjdk-17-jdk git unzip curl

# Flutter stable
git clone https://github.com/flutter/flutter.git -b stable ~/dev/flutter
export PATH="$HOME/dev/flutter/bin:$PATH"

# Android command line tools
mkdir -p ~/Android/Sdk/cmdline-tools && cd /tmp
curl -fsSLO https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip
unzip -q commandlinetools-linux-15859902_latest.zip
mv cmdline-tools ~/Android/Sdk/cmdline-tools/latest
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

flutter doctor
```

## Lancer

```bash
flutter pub get
dart run build_runner build          # génère le code Drift
flutter run                          # sur un appareil Android branché
```

## Tester

```bash
flutter analyze                      # doit être vide
flutter test                         # cœur : URL, flux, extraction, EPUB, base, SMTP
dart tool/epubcheck.sh               # valide les EPUB générés par les tests
```

## Configurer l'envoi

Dans **Réglages** :

1. votre adresse Kindle `nom@kindle.com`
   (Amazon → *Contenu et appareils* → *Préférences* → *Paramètres des documents personnels*) ;
2. le serveur SMTP, par défaut `smtp.gmail.com` port 587 (STARTTLS) ;
3. un **mot de passe d'application** Gmail, jamais votre mot de passe normal ;
4. l'adresse expéditeur, qui doit figurer dans la liste des expéditeurs autorisés de
   votre compte Amazon, sinon Amazon ignore le document sans erreur SMTP.

Le bouton **Tester l'envoi** envoie un mini EPUB. Amazon peut mettre quelques minutes à
convertir le livre.

## Licence

Usage strictement personnel. L'application ne republie rien : elle fabrique un fichier
que vous ouvrez sur votre propre liseuse.

Libron est sous licence OFL, voir `assets/fonts/`.