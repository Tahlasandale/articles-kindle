# Articles vers Kindle — spécification

**Version** : 1.0 — 14 octobre 2026
**Cible** : application mobile Flutter (Android)
**Liseuse** : Kindle 7e génération

> Cette spécification amendée intègre les décisions de conception prises avec
> l'utilisateur. Les écarts par rapport à la spec d'origine sont justifiés dans
> [`../DECISIONS.md`](../DECISIONS.md) ; ils sont signalés ici par la mention
> *(écart §N)*.

---

## 1. Contexte et objectifs

L'utilisateur veut lire sur sa liseuse les articles web qui l'intéressent, sans passer
par un service tiers. L'application met des articles de côté, puis génère un livre EPUB
et l'envoie à la Kindle par e-mail, sur déclenchement manuel.

**Objectifs**

- Ajouter un article en deux gestes depuis n'importe quelle application (menu « Partager »).
- Extraire un contenu lisible (sans pub ni menus) et le convertir en EPUB.
- Envoyer l'EPUB à l'adresse `@kindle.com` via SMTP.
- Fonctionner sans serveur : tout tourne sur le téléphone.

**Hors périmètre (v1)** — *(écart §3.2 et §7.3)*

- Abonnement et rafraîchissement automatique de flux RSS.
- Tâche planifiée quotidienne en arrière-plan (peu fiable sur mobile).
- Synchronisation multi-appareils, comptes utilisateurs.
- Lecture des articles dans l'app (la lecture se fait sur la Kindle).
- Gestion des sites derrière paywall ou authentification.
- iOS *(écart §18.1)*.

## 2. Utilisateur et cas d'usage

Utilisateur unique, technophile, qui lit sur Kindle 7e génération et suit une quinzaine
de blogs auto-hébergés et de sites d'actualités.

| Cas | Déclencheur |
|---|---|
| UC1 Sauvegarder un article | Partager une URL depuis le navigateur vers l'app |
| UC2 Ajouter les articles d'un site | Coller l'URL d'un blog, choisir « articles du site », cocher |
| UC3 Choisir quoi envoyer | Cocher/décocher dans la liste |
| UC4 Envoyer à la Kindle | Bouton « Envoyer à la Kindle » |
| UC5 Configurer l'envoi | Écran Réglages (SMTP, adresse Kindle) |

## 3. Exigences fonctionnelles

### 3.1 Articles

- **F1** : recevoir une URL via le menu Partager (Android Share Intent).
- **F2** : ajouter une URL manuellement (champ + presse-papiers).
- **F3** : à l'ajout, récupérer le titre et la source en arrière-plan ; l'article passe de
  l'état `pending` à `ready`.
- **F4** : supprimer, rechercher, étiqueter un article.
- **F5** : détecter les doublons (même URL normalisée).
- **F6** *(nouveau)* : « articles du site » — partir de l'URL d'un blog, découvrir son
  flux (`link rel="alternate"` type `application/rss+xml`), proposer les éléments à
  cocher, les ajouter comme candidats. Sans abonnement, sans rafraîchissement.

### 3.2 Découverte par flux *(remplace §3.2 de la spec d'origine)*

- **F7** :.elements audio et vidéo ignorés (on ne fait pas un livre de podcasts).
- **F8** : si l'élément porte `content:encoded`, ce texte est utilisé tel quel et la page
  n'est pas téléchargée ; sinon la page est extraite.
- **F9** : les éléments proposés ne sont jamais ajoutés d'office.

### 3.3 Génération et envoi

- **F10** : l'écran « Envoi » liste les articles prêts, tous cochés par défaut,
  réordonnables à la main.
- **F11** : un seul EPUB par envoi : un chapitre par article, une table des matières.
- **F12** : envoi par SMTP à l'adresse Kindle, pièce jointe `.epub`.
- **F13** : après succès, les articles passent à `sent` et restent consultables dans
  l'historique, non renvoyés par défaut.
- **F14** : en cas d'échec, rien n'est marqué envoyé ; l'utilisateur peut réessayer.
- **F15** *(amendée)* : au-delà du seuil de taille, l'app **alerte** et propose de retirer
  des articles ou de désactiver les images. Pas de découpe automatique.

### 3.4 Réglages

- **F16** : adresse Kindle, serveur SMTP, port, chiffrement, identifiant, mot de passe,
  adresse expéditeur. Préréglage Gmail `smtp.gmail.com:587` STARTTLS.
- **F17** : bouton « Tester l'envoi » avec un mini EPUB.
- **F18** : options : télécharger les images (défaut oui), niveaux de gris (défaut oui),
  largeur max des images (800 px), seuil de taille (25 Mo), thème, purge du contenu
  envoyé.

## 4. Exigences non fonctionnelles

- **Confidentialité** : aucune donnée n'est envoyée ailleurs que vers les sites d'articles
  et le serveur SMTP configuré. Pas de télémétrie, pas de service tiers.
- **Sécurité** : mot de passe SMTP dans le Keystore / Keychain, jamais journalisé ; TLS
  obligatoire, mode non chiffré refusé.
- **Robustesse** : un article en échec n'empêche pas la génération des autres.
- **Hors-ligne** : les articles et le contenu déjà extrait restent consultables sans
  réseau ; l'envoi exige une connexion.
- **Performance** : extraction de 20 articles en moins de 60 s sur une connexion
  standard, deux requêtes simultanées au maximum par domaine.
- **Accessibilité** : textes redimensionnables, contrastes conformes, thème sombre.
- **Langue** : interface en français, structure prête pour l'internationalisation (ARB).

## 5. Architecture

```
UI (écrans, widgets)
   │
État (Riverpod : notifiers / providers)
   │
Services métier
   ├─ ArticleService      (ajout, statuts, doublons)
   ├─ SiteDiscoveryService(découverte de flux, liste d'articles d'un site)
   ├─ ExtractionService   (téléchargement + contenu lisible)
   ├─ EpubBuilder         (génération du fichier)
   └─ KindleMailer        (envoi SMTP)
   │
Données
   ├─ Base SQLite (Drift)
   ├─ Système de fichiers (cache images, EPUB temporaires)
   └─ Stockage sécurisé (identifiants SMTP)
```

**Principes**

- Les services sont indépendants de l'UI et testables en Dart pur.
- Le réseau passe par une interface `ArticleFetcher` injectée ; l'implémentation réelle
  utilise `dio`, les tests fournissent des réponses enregistrées. Aucun test ne touche
  le réseau.
- Le traitement lourd (extraction, génération EPUB, images) s'exécute dans un isolate.
- Le SMTP passe par une interface `MailTransport` injectée ; les tests utilisent un faux
  transport en mémoire.

## 6. Choix techniques

| Besoin | Paquet | Remarque |
|---|---|---|
| Partage entrant | `receive_sharing_intent` 1.9+ | `singleTask` + `intent-filter` SEND dans le Manifest |
| Base locale | `drift` 2.35 + `sqlite3` 3.x | **pas** `sqlite3_flutter_libs` (mort) — voir DECISIONS |
| Migrations | `drift_dev` / `build_runner` | schéma typé, tests sur base en mémoire |
| État | `flutter_riverpod` 3.x | `StateNotifier` n'existe plus en 3.x |
| Navigation | `go_router` 18.x | exige Flutter ≥ 3.44 |
| HTTP | `dio` 5.x | derrière `ArticleFetcher` |
| Flux RSS/Atom | `xml` | parsing écrit pour ce projet, pas `webfeed_plus` (figé 2024) |
| HTML | `html` 0.15.x | parsing et nettoyage du DOM |
| Extraction lisible | *maison* | score de densité, pas de port de Readability |
| EPUB | `archive` 4.x | `mimetype` non compressé en première entrée |
| SMTP | `mailer` 7.x | STARTTLS 587, SSL 465, pièces jointes |
| Secrets | `flutter_secure_storage` | mot de passe SMTP |
| Fichiers | `path_provider` | cache et EPUB temporaires |
| Images | `image` 4.x | redimensionnement, niveaux de gris, dans un isolate |
| Typographie | Libron (OFL) | `nicoverbruggen/libron`, embarquée dans l'app seulement |

## 7. Flux principaux

### 7.1 Ajout d'un article

1. L'utilisateur partage une URL, ou la saisit, ou la choisit parmi les articles d'un site.
2. L'app normalise l'URL (suppression des paramètres `utm_*`, du fragment, `www` selon
   la règle) et vérifie les doublons.
3. Insertion en base avec le statut `pending`.
4. `ExtractionService` télécharge la page, extrait titre, auteur, date, contenu lisible et
   images.
5. Mise à jour : statut `ready`, ou `failed` avec un message d'erreur.

### 7.2 Extraction du contenu lisible

- Télécharger le HTML (timeout 15 s, taille maximale bornée).
- Résoudre l'encodage (en-tête HTTP, balise `meta charset`).
- Supprimer `script`, `style`, `nav`, `aside`, `footer`, formulaires, publicités.
- Choisir le nœud de contenu principal (balises `article`/`main`, sinon score par
  densité de texte et de paragraphes, en pénalisant les liens et les classes bruyantes).
- Convertir en XHTML valide, liens et images en URL absolues, attributs d'événements
  retirés.
- Comparaison en développement avec le rendu de `curl.md` (voir `CURL.md`), jamais en
  test.
- Plan B : une page rendue en JavaScript est marquée `failed` avec un lien « Ouvrir dans
  le navigateur ». L'extraction WebView est une évolution (v2).

### 7.3 Articles d'un site *(nouveau)*

1. L'utilisateur colle l'URL d'un blog.
2. L'app télécharge la page, cherche `link[rel=alternate][type=application/rss+xml]`, puis
   l'URL du flux dans `<a>` si rien n'est déclaré.
3. Le flux est parsé (RSS 2.0 ou Atom) et les éléments sont listés à cocher.
4. Les éléments cochés sont ajoutés en `pending` et extraits comme au §7.1, en utilisant
   `content:encoded` lorsqu'il est présent.

### 7.4 Envoi à la Kindle

1. L'utilisateur ouvre l'écran « Envoi » et vérifie la sélection.
2. L'app estime la taille ; au-delà du seuil, elle alerte.
3. `EpubBuilder` génère le livre dans un dossier temporaire.
4. `KindleMailer` envoie le message avec l'EPUB en pièce jointe.
5. Succès : articles marqués `sent`, date enregistrée, fichier temporaire supprimé.
6. Échec : message explicite (authentification, réseau, taille) et réessai possible.

**États d'un article** : `pending → ready → sent`, avec `failed` réessayable.

## 8. Génération EPUB

EPUB 3, avec `toc.ncx` de compatibilité pour la conversion Amazon.

```
mimetype                      (premier fichier, non compressé)
META-INF/container.xml
OEBPS/content.opf
OEBPS/nav.xhtml
OEBPS/toc.ncx
OEBPS/chapters/ch001.xhtml …
OEBPS/images/…
OEBPS/styles.css
```

**Règles**

- Titre du livre : « Lectures du JJ/MM/AAAA », modifiable.
- Chaque chapitre commence par titre, source, auteur, date et lien d'origine.
- Style e-ink : `Georgia, 'Times New Roman', serif`, corps 11,5, un saut de page par
  article. **Aucune police embarquée** — le Kindle ne les conserve pas.
- Images : largeur max 800 px, JPEG, niveaux de gris par défaut.
- Taille : alerte au-delà de 25 Mo, Amazon refusant au-delà de 50 Mo.
- Validation : `epubcheck` est une porte bloquante.

## 9. Envoi vers la Kindle

- Adresse de destination `nom@kindle.com`, visible dans Amazon → *Contenu et appareils* →
  *Préférences* → *Paramètres des documents personnels*.
- L'adresse expéditeur doit figurer dans la liste des e-mails autorisés du compte
  Amazon, sinon le document est ignoré sans erreur côté SMTP.
- Amazon convertit l'EPUB pour la Kindle 7e génération ; la livraison peut prendre
  quelques minutes.
- Gmail et Outlook demandent un mot de passe d'application. Port 587 (STARTTLS) ou
  465 (SSL).
- Sujet et corps du message sans importance ; le nom du fichier devient le titre du livre.

## 10. Modèle de données (SQLite)

**`articles`**

| Champ | Type | Notes |
|---|---|---|
| id | int PK | |
| url | text unique | URL normalisée |
| title | text null | |
| author | text null | |
| site_name | text null | |
| site_url | text null | site d'origine, pour « articles du site » |
| published_at | datetime null | |
| origin | text | `share`, `manual`, `site` |
| status | enum | `pending`, `ready`, `failed`, `sent` |
| error | text null | |
| content_html | text null | XHTML nettoyé |
| content_source | text null | `page` ou `feed` |
| created_at | datetime | |
| sent_at | datetime null | |
| selected | bool | coché pour le prochain envoi |
| sort_index | int | ordre choisi à la main |

**`tags`** (id, name unique) · **`article_tags`** (article_id, tag_id)

**`article_images`** (id, article_id, source_url, local_path, mime_type)

**`settings`** (key PK, value)

**`deliveries`** (id, sent_at, article_count, file_size, success, error)

Hors base : mot de passe SMTP (Keystore).

## 11. Interface utilisateur

**Onglets** *(écart §11 : pas d'onglet « Flux »)*

1. **À lire** — articles `pending`/`ready`/`failed`, cases à cocher, glisser pour
   supprimer, étiquettes, bouton flottant « Ajouter » (URL ou articles du site).
2. **Envoyer** — récapitulatif (nombre, taille estimée), réordonnable, bouton
   « Envoyer à la Kindle », progression par étapes.
3. **Historique** — envois passés et articles envoyés, journal des échecs, « remettre dans
   la file », purge.
4. **Réglages** — SMTP, adresse Kindle, options d'EPUB, thème, purge.

**Design system** *(voir DECISIONS)* — noir et blanc purs, mode sombre inversé, coins
carrés, liseré de 1 px, aucune ombre, Libron partout, statut par mot et symbole, thème à
trois états avec bouton dans la barre supérieure.

**États à couvrir** : liste vide (explication et exemples), erreur réseau, extraction
échouée avec « Réessayer » et « Ouvrir dans le navigateur ».

## 12. Sécurité et confidentialité

- Mot de passe SMTP uniquement dans le Keystore, jamais journalisé.
- TLS obligatoire pour SMTP ; le mode non chiffré est refusé.
- Nettoyage du HTML : suppression des scripts et des attributs d'événements.
- User-Agent honnête, deux requêtes simultaines au maximum par domaine.
- Sauvegarde Android (`allowBackup`) désactivée pour la base contenant l'historique.
- Pas de télémétrie.

## 13. Gestion des erreurs

| Situation | Comportement |
|---|---|
| URL invalide | Message immédiat, rien n'est enregistré |
| Page inaccessible (404, timeout) | Article `failed`, bouton « Réessayer » |
| Page sans contenu exploitable | `failed` avec raison, lien « Ouvrir dans le navigateur » |
| Flux introuvable sur le site | Message explicite, l'URL reste saisie |
| Authentification SMTP refusée | Message guidant vers le mot de passe d'application |
| Pièce jointe trop grosse | Alerte avant envoi, proposition de retirer des articles |
| Pas de réseau pendant l'envoi | Aucun changement d'état, réessai possible |

## 14. Stratégie de test

- **Unitaires, TDD sur le cœur** : normalisation d'URL, parsing de flux, extraction sur un
  corpus figé, génération EPUB, requêtes Drift sur base en mémoire, `KindleMailer` sur
  faux transport.
- **Corpus** : `test/fixtures/html/` contient des pages réelles figées, scripts et
  trackers retirés, couvrant les sites de `SmartRSS-subscriptions-20261013.xml` et une
  dizaine de sites outsiders difficiles.
- **Validation EPUB** : `epubcheck` sur chaque fichier généré par les tests.
- **Aucun test ne touche le réseau.**
- **Manuel** : checklist sur appareil Android — partage, rendu du livre, table des
  matières, réception sur la Kindle 7e génération.

## 15. Plan de livraison

| Jalon | Contenu |
|---|---|
| M1 – Socle | Projet, base Drift, design system, écran « À lire », ajout manuel |
| M2 – Extraction | Téléchargement, contenu lisible, statuts, gestion d'erreurs |
| M3 – EPUB + envoi | `EpubBuilder`, `KindleMailer`, Réglages, APK debug |
| M4 – Partage et découverte | Share Intent Android, « articles du site » |
| M5 – Finitions | Historique enrichi, thème, icône, publication |

Le premier usage réel — lien → EPUB → Kindle — est atteint à M3.

## 16. Risques et points d'attention

- **Qualité de l'extraction** : risque principal. Corpus de test, score de densité,
  comparaison avec `curl.md` en développement.
- **Sites rendus en JavaScript ou protégés** : certains articles échoueront, accepté en v1.
- **Politique d'Amazon** : l'envoi par e-mail peut évoluer ; alternative : transfert USB.
- **Fournisseurs e-mail** : durcissement possible des règles SMTP.
- **Droits d'auteur** : usage strictement personnel, l'app ne republie rien.
- **iOS** : le Share Extension demandera un App Group et du code natif.

## 17. Évolutions possibles

- Envoi planifié (workmanager) en mode « au mieux ».
- Import/export OPML.
- Extraction par WebView pour les pages dynamiques.
- Réglage par site (nombre max d'articles, filtre par mots-clés).
- Import depuis Pocket/Instapaper.
- Synchronisation chiffrée entre appareils.
- Publication sur le Play Store.

## 18. Questions ouvertes — résolues

1. **Android seul en v1** : oui, iOS plus tard.
2. **Fournisseur SMTP** : Gmail par défaut, préréglages STARTTLS.
3. **Flux RSS** : pas d'abonnement ; découverte de site à la demande, éléments cochés
   un par un.
4. **Contenu après envoi** : conservé, avec purge manuelle depuis les Réglages et
   l'Historique.