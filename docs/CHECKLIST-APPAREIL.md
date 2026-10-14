# Valider sur votre téléphone

Aucun appareil Android n'était branché pendant le développement : ce qui suit est
la recette à exécuter chez vous, dans l'ordre. Dix minutes pour la première
fois, une par Test ensuite.

L'APK se construit avec :

```bash
export PATH="$HOME/dev/flutter/bin:$PATH"
export JAVA_HOME="$HOME/dev/jdk17"
export ANDROID_HOME="$HOME/Android/Sdk"
flutter build apk --debug      # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release    # build/app/outputs/flutter-apk/app-release.apk
```

Choisissez le **debug** pour essayer tout de suite. Le release est plus léger
(67 Mo contre 209 Mo, qui contient toutes les architectures et les symboles), mais
il est signé avec le certificat de débogage : il s'installe, et c'est tout. Le Play
Store le refusera, et le remplacer plus tard par une version signée avec votre
clé imposera une désinstallation préalable.

L'installer sans câble :

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 1. L'application s'ouvre

| Attendu | Comment vérifier |
|---|---|
| Le nom « Articles vers Kindle » apparaît sous l'icône |Launcher |
| Les quatre onglets sont là : À lire, Envoyer, Historique, Réglages | Bas de l'écran |
| « À lire » est vide et explique quoi faire | Écran d'accueil |
| Le thème suit le téléphone, le bouton en haut à droite bascule clair/sombre/système | Barre supérieure |

## 2. Partager un article

C'est le geste principal, il doit marcher depuis **n'importe quel** navigateur.

1. Ouvrir un article dans Chrome, Firefox ou le navigateur du fabricant.
2. Menu **Partager**.
3. Choisir **Articles vers Kindle** dans la liste.
4. L'application s'ouvre, une bandeau dit « Prêt », puis vous revenez au navigateur.

| Attendu | Si ça ne marche pas |
|---|---|
| L'application apparaît dans la liste des partageurs | Elle n'est pas proposée : le `intent-filter` n'est pas lu |
| Le bandeau apparaît en quelques secondes | L'extraction a échoué : ouvrez « À lire » et lisez le motif sur l'article |
| Le bandeau dit « Prêt » | « Échec » : le site bloque, l'URL ou le lien est mort |
| L'article est visible dans l'onglet **À lire** | Le partage n'a pas été traité : shares pris au démarrage plutôt qu'à l'ouverture |

Partager deux fois le **même** article doit annoncer « Cet article est déjà dans
la liste », pas en créer un second.

Partager un texte du genre « Regarde ça : https://… » doit ajouter l'article :
c'est l'adresse qui compte, pas la phrase.

## 3. Envoyer à la Kindle

### Réglages

1. **Réglages** → adresse Kindle (`nom@kindle.com`, trouvée dans Amazon →
   *Contenu et appareils* → *Préférences* → *Paramètres des documents personnels*).
2. Identifiant Gmail, mot de passe d'**application** (jamais votre mot de passe
   normal : compte Google → *Sécurité* → *Validation en 2 étapes* → *Mots de passe
   d'application*), adresse expéditeur.
3. **Tester l'envoi**.

| Attendu | Signification |
|---|---|
| « Message de test accepté par le serveur » | SMTP, mot de passe et destinataire sont bons |
| « Authentification refusée » | Le mot de passe d'application est expiré, absent ou mal collé |
| « Connexion au serveur impossible » | Pas de réseau, ou le serveur SMTP est bloqué |

**Le piège d'Amazon** : si l'adresse expéditeur n'est pas dans la liste des
expéditeurs autorisés de votre compte Amazon, le message part sans erreur SMTP et
**le livre n'arrive jamais**. C'est la raison la plus fréquente d'un « ça a marché
mais rien n'arrive ».

### Le livre

1. Onglet **Envoyer** : la liste contient les articles cochés.
2. La taille estimée s'affiche. Au-delà du seuil, l'app demande confirmation.
3. **Envoyer à la Kindle**.
4. « Livre envoyé. Amazon le convertit pour votre Kindle. »

Sur la liseuse, quelques minutes plus tard :

| Attendu | Si ça ne marche pas |
|---|---|
| Le livre apparaît dans vos documents | Amazon a ignoré le message : vérifiez l'expéditeur autorisé |
| La table des matières liste les articles, dans l'ordre choisi | L'ordre a changé : refaites la sélection |
| Chaque article commence sur une page, avec titre, source et date | La mise en page n'a pas été respectée |
| Les liens cliquables dans le texte restent cliquables | L'extraction a perdu les URL absolues |
| Les images existent et sont lisibles en niveaux de gris | Option « Télécharger les images » à vérifier dans les Réglages |
| La police est une serif lisible, pas une policeillisible | La police embarquée a été retirée par Amazon : c'est attendu |

## 4. Un site entier

Onglet **À lire** → bouton **+** → *Articles d'un site* → l'adresse d'un blog que
vous suivez → *Chercher les articles*.

| Attendu | Si ça ne marche pas |
|---|---|
| La liste des articles du site s'affiche avec des cases | « Aucun flux d'articles n'a été trouvé » : le site ne déclare pas de flux |
| Un podcast ou une chaîne YouTube est refusé | C'est voulu : on ne fabrique pas de livre de podcast |
| Ajouter les articles cochés les fait apparaître dans « À lire », prêts | Le flux donnait déjà le texte, la page n'a pas été téléchargée |

## 5. Ce qui n'est pas vérifié ici

- Le partage réel : testé sur le code et sur l'extraction des URL, pas sur un
  appareil.
- La réception sur la Kindle : c'est votre liseuse qui répondra.
- Les articles en JavaScript : ils échouent, c'est accepté pour cette version.
- iOS : hors périmètre.