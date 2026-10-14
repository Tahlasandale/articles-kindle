# Corpus de fixtures HTML

Pages d'articles **figées sur disque** pour tester l'extraction de contenu lisible
(texte, titre, auteur, date, images) et sa fabrication en EPUB.

- **Source des URL** : `docs/SmartRSS-subscriptions-20261013.xml` (OPML exporté par SmartRSS).
- **Date de capture** : 2026-10-14. Chaque page a été téléchargée **une seule fois** et figée.
- **Nettoyage** : `tools/clean_html.py` (Python 3, stdlib uniquement).
- **Aucun fichier ne dépasse 2 Mo** — le plus volumineux fait 370 Ko.

## Règles de nettoyage appliquées

`tools/clean_html.py <source.html> <destination.html>` retire :

| Élément | Détail |
|---|---|
| `<script>` | contenu + balise (incl. `application/ld+json`, Google Analytics, GTM, Matomo…) |
| `<noscript>` | contenu + balise |
| `<iframe>` / `<object>` / `<embed>` | contenu + balise |
| `<link rel=…>` | uniquement `preconnect`, `preload`, `dns-prefetch`, `prefetch`, `prerender`, `modulepreload`, `manifest` |
| Attributs `src` / `srcset` / `poster` | retirés s'ils pointent vers un domaine de tracking connu (`googletagmanager`, `google-analytics`, `doubleclick`, `googlesyndication`, `googleadservices`, `ads-twitter`, `hotjar`, `segment`, `amplitude`, `licdn`, `adsrvr`, `termina`, `metrika`) |
| Commentaires « poubelle » | commentaires conditionnels IE (`<!--[if …]>`) et commentaires contenant un `<script>`/`<iframe>`/`<noscript>` masqué |

**Ce qui n'est PAS touché** : le contenu éditorial de l'article, les balises
`<style>`, les `<link rel="stylesheet">`, les attributs `class`/`alt`/`title`,
les `<figure>`/`<figcaption>`, les blocs `<pre>`/`<code>`, les commentaires HTML
ordinaires, les balises `<video>`/`<audio>` et le `<audio>` de podcast.

Garde-fous du script : si le fichier dépasse 2 Mo, les images `data:` base64
sont retirées, puis les commentaires, et en dernier recours le fichier est
plafonné. **Aucun fixture n'a nécessité ces garde-fous.**

## Inventaire des fixtures

Format : `fichier | site | type de page | difficulté | ce qui doit être extrait`

### selfh.st (3 fixtures)

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `selfh.st/weekly-2026-10-09.html` | selfh.st | newsletter hebdo (Astro + Alpine.js) | moyen | le corps de la lettre « Self-Host Weekly » (titres de sections + résumés + liens), sans la barre de progression, le menu et le pied de page |
| `selfh.st/weekly-2026-10-02.html` | selfh.st | newsletter hebdo (Astro + Alpine.js) | moyen | idem, numéro du 2 octobre |
| `selfh.st/survey-2026-open.html` | selfh.st | page d'annonce (hors article) | facile | le texte court « 2026 Self-Host User Survey: Open for Submissions » |

> Piège : Astro + Alpine laisse des attributs `x-data` / `@scroll.window` /
> `data-progress-bar` full de code JavaScript littéral. Un extracteur naïf qui
> prend le `body` brut va embarquer du code.

### bison-blog (3 fixtures) — Ghost

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `bison-blog/from-bouse-to-tank.html` | BisonBlog (Ghost) | billet court | facile | titre + texte du récit, 5 tags, date |
| `bison-blog/ordinateurs-qui-font-rever.html` | BisonBlog (Ghost) | billet | facile | le texte et la liste des Fairy |
| `bison-blog/mes-outils-bureautiques-pour-ne-plus-dependre-des-gafam.html` | BisonBlog (Ghost) | billet illustré | facile | le texte + les 12 images (`alt` conservés) et les liens externes |

> Cas de référence « propre » : contenu dans `<article>` / `<main>`, `<meta
> property="og:*">` corrects, nav minuscule. Sert de contrôle positif.

### dadall (3 fixtures) — blog PHP maison, thème Skya

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `dadall/velo-sigma-blaze-et-impression-3d.html` | dadall.info | billet photo (8 images) | moyen | le texte du billet + légendes, pas l'aside « Fédosphere / Archives » ni l'widget Pixelfed |
| `dadall/bloquer-version-nodejs-pour-mastodon-420.html` | dadall.info | billet technique | moyen | le texte et les blocs de commande |
| `dadall/jai-recupere-un-pinephone.html` | dadall.info | billet technique (7 images) | moyen | le texte du billet |

> Pièges : pas de `<main>` (le contenu est dans un `<div>` de contenu +
> `<aside>`) ; encadré d'avertissement « Attention, ce billet se traîne depuis
> plus de 3 mois » avant le titre ; **commentaires HTML non fermés** dans la
> source qui masquent du balisage ; sidebar très bavarde ; `<article>` présent
> mais purement décoratif.

### blog-stephane-robert (3 fixtures) — Zola + pagefind, bilingue

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `blog-stephane-robert/roadmap-publique-maintenir-formations.html` | blog.stephane-robert.info | billet long | difficile | le corps du billet uniquement, hors méga-menu (6 `<nav>`), sidebar « Learning Path / Formations / Labs » (4-5 `<aside>`) et widget Ko-fi |
| `blog-stephane-robert/chainguard-actions-plumber-securite-cicd.html` | blog.stephane-robert.info | billet long | difficile | idem |
| `blog-stephane-robert/npm-scripts-installation-desactives.html` | blog.stephane-robert.info | billet long + blocs de code | difficile | idem, en préservant l'indentation des `<pre>` |

> Pièges : ~15 500 caractères visibles pour ~1 500 utiles ; sélecteur de langue
> FR/EN, recherche pagefind (Ctrl+K), 26 commentaires, 116-119 liens.

### framablog (3 fixtures) — WordPress, podcast / newsletter

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `framablog/khryspresso-du-lundi-12-octobre-2026.html` | framablog.org | Transcription d'épisode de podcast (50 000 caractères de texte) | difficile | les **notes de l'épisode** (liste de liens commentés), le résumé et la date — pas la nav Framasoft, pas la liste des podcasts, pas le formulaire d'abonnement |
| `framablog/khryspresso-du-lundi-28-septembre-2026.html` | framablog.org | idem, épisode du 28 septembre | difficile | idem |
| `framablog/chapo-upload2-le-solarpunk-pour-toutes-et-tous.html` | framablog.org | newsletter mensuelle Framasoft (134 liens) | difficile | le corps de la newsletter « Upload² » et sesliens, hors blocs podcasts/inscription |

> Pièges : le `<title>` du document est une accroche de la home (**« … mais ce
> serait peut-être l'une des plus grandes opportunités manquées de notre époque
> si le logiciel libre ne libérait rien d'autre que du code »**) et non le titre
> de l'article → l'extraction du titre ne doit **pas** se fier à `<title>`.
> Le texte utile est majoritairement une **liste de liens** : le score de
> densité de `<p>` est un mauvais signal ici.

### lemotdejay (3 fixtures) — WordPress + Google Tag Manager

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `lemotdejay/le-cirad-revient-a-la-maison.html` | lemotdejay.fr | billet long illustré (28 images) | moyen | le texte du billet, sans le badge « Certifié d'origine par un organisme indépendant » ni le menu à 2 niveaux |
| `lemotdejay/regarde-maman-on-repare-lavion.html` | lemotdejay.fr | billet | moyen | le texte du billet |
| `lemotdejay/degooglisation-google-docs-vers-fichiers-office.html` | lemotdejay.fr | billet technique + script | moyen | le texte et le bloc de code |

> Piège : GTM et Gravatar sont chargés via `<script>`/`src` — c'est exactement ce
> que le nettoyage retire, la fixture est donc le cas « déjà assaini ».

### korben (3 fixtures) — WordPress sur mesure, méga-menu

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `korben/ported2browser-200-jeux-dans-le-navigateur.html` | korben.info | billet court | difficile | **5 000 caractères utiles** noyés dans 7 700 de texte et 166 liens ; le titre est préfixé par le nom du site (« Ported2Browser - +200 jeux dans le navigateur - Korben ») |
| `korben/reverse-engineering-par-agent-ia-test.html` | korben.info | billet | difficile | le corps du billet, hors méga-menu (13 `<nav>`) et bloc « Korben.info reste gratuit grâce à ses lecteurs / Patreon » |
| `korben/macspace-donnees-systeme-mac.html` | korben.info | billet | difficile | idem |

> Pièges : 13 blocs `<nav>` en tête, sidebar « Soutenir / Newsletter », 49-54
> images de partage social, 3 formulaires, `<noscript>` de repli. Le texte
> éditorial ne représente qu'environ un tiers du texte visible.

### code.gouv.fr (3 fixtures) — site statique, design system DSFR

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `code.gouv.fr/bluehat-grist-2025.html` | code.gouv.fr | note BlueHat très courte (≈2 500 caractères) | moyen | le titre et le corps de la note « Grist », pas le bandeau République française ni le menu (44 liens) |
| `code.gouv.fr/bluehat-recoco-2025.html` | code.gouv.fr | note BlueHat | moyen | idem (« Recommandations-collaboratives ») |
| `code.gouv.fr/bluehat-terreze.html` | code.gouv.fr | note BlueHat | moyen | idem (« Terreze ») |

> Pièges : **pas de `<article>` ni de balise sémantique de contenu**, tout est
> dans un `<main>` ; le contenu utile est très court face à la navigation ;
> blocs de liens sociaux (Mastodon / PeerTube) et iframes de partage retirés
> par le nettoyage.

### sansdependances (3 fixtures) — Astro + Tailwind

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `sansdependances/todo-txt-outils-aussi-simples-que-ca.html` | sansdependances.fr | témoignage | moyen | le texte du témoignage ; les classes utilitaires Tailwind dans `class` contiennent `[&>li>a]` → piège pour un parseur d'attributs naïf |
| `sansdependances/craft-le-adobe-killer.html` | sansdependances.fr | témoignage | moyen | le texte du témoignage |
| `sansdependances/reprendre-en-main-mes-livres-numeriques-des-drm-a-koreader.html` | sansdependances.fr | témoignage | moyen | le texte du témoignage |

> Le titre commence par `(témoignage) ` → à conserver tel quel.

### stackgui (3 fixtures) — Astro, template commercial

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `stackgui/pennylane-nouveau-module-reporting.html` | stackgui.de | billet | facile | le titre, la date (`3 sept. 2026`), l'auteur et le corps du billet, pas le bandeau « Besoin d'aide pour choisir les bons outils ? » ni le menu Services |
| `stackgui/pipedrive-mcp-claude-chatgpt-gemini.html` | stackgui.de | billet | facile | idem |
| `stackgui/tests-utilisateur-equipes-produit.html` | stackgui.de | billet | facile | idem |

> Pages très propres : contenu dans `<article>`, nav à 1 entrée, aucun tracker.

### sebsauvage-liens (3 fixtures) — cibles externes du linkblog

sebsauvage.net est un **linkblog** : on ne fige pas la page des liens, on fige les
**sites vers lesquels il pointe** (ce sont eux qu'il faut savoir extraire).

| fichier | site | type | difficulté | ce qui doit être extrait |
|---|---|---|---|---|
| `sebsauvage-liens/phoronix-linux-cram-compressed-ram.html` | phoronix.com | news Linux (WordPress) | moyen | le corps de la news « Meta Developing Compressed RAM "CRAM" For Linux » ; attention à la navigation `Catégories` et aux blocs « Popular Categories » |
| `sebsauvage-liens/next-ink-cles-usb-e-dogs.html` | next.ink | billet de blog (Next INpact) | difficile | le billet « Clés USB, smartphones… les e-dogs flairent le tantale », son auteur (Sébastien Gavois) et sa date ; exclure les 41 commentaires et la barre de liens de podcasts |
| `sebsauvage-liens/arretsurimages-lyceennes-matraque-partout.html` | arretsurimages.net | **cas négatif : rendu 100 % client** | difficile | **rien** — le corps de l'article n'est pas dans le HTML. Sert à vérifier que l'extracteur échoue proprement (pas de crash, pas de CSS parasite renvoyé comme article) au lieu de fabriquer un EPUB de 3 Ko de CSS |

## Sites injoignables

| site | diagnostic |
|---|---|
| **ldtr.ovh** (Loïs Dutour) | Hors service. Le DNS résout (`88.137.172.16`) mais `/`, `/index.html`, `http://` et le flux `https://ldtr.ovh/index.xml` renvoient tous **404**. Aucune fixture possible ; à rejouer quand le blog revient. |
| **The Register** (cible externe de sebsauvage) | Renvoie **404** sur les deux variantes d'URL de l'article — comportement anti-bot classique du site. Remplacé par phoronix.com / next.ink dans le corpus. |

Non retenus, hors périmètre « articles » : BURGER RING (flux podcast), YouTube
(Underscore_), categpt.chat et rss.evangelizo.org (flux, pas de page d'article).

## Les 3 cas limites recommandés

1. **`framablog/khryspresso-du-lundi-12-octobre-2026.html`** — 50 000 caractères
   utiles, majoritairement sous forme de **liste de liens**, dans une page WordPress de
   podcast dont le `<title>` est une accroche de home. Casse simultanément la
   détection du titre, le score de densité de paragraphes et le découpage
   nav/contenu.
2. **`korben/ported2browser-200-jeux-dans-le-navigateur.html`** — article réel
   très court noyé dans 13 blocs `<nav>`, 166 liens, 49 images de partage social
   et une sidebar de financement. Casse le choix du « plus gros bloc de texte »
   et le nettoyage des liens de partage.
3. **`sebsauvage-liens/arretsurimages-lyceennes-matraque-partout.html`** — page
   dont **aucun contenu éditorial n'est présent dans le HTML** (SPA). Vérifie le
   comportement à froid : l'extracteur doit renvoyer une erreur propre ou un
   résultat vide, jamais un EPUB rempli de CSS.

Accessoires utiles mais moins extrêmes : `blog-stephane-robert/*.html` (bruit de
navigation massif sur article valide) et `selfh.st/weekly-*.html` (attributs JS
Alpine dans le HTML).

## Régénérer le corpus

Le script de nettoyage est versionné ici pour que le corpus soit reproductible :

```sh
python3 test/fixtures/tools/clean_html.py page-telechargee.html test/fixtures/html/<site>/<slug>.html
```

Le téléchargement lui-même n'est pas scripté : les fixtures sont figées, donc
elles ne sont pas supposed être re-téléchargées à chaque exécution de test.