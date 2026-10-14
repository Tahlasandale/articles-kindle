# curl.md — oracle d'extraction

[curl.md](https://curl.md/) est un service de **wevm** qui transforme une page web en
Markdown optimisé pour les agents.

```bash
curl curl.md/korben.info/un-exemple-d-article
curl curl.md/example.com --objective "l'essentiel en 3 points"
curl https://curl.md/docs --header "Accept: text/markdown"
```

Site : <https://curl.md> · code : <https://github.com/wevm/curl.md>

## À quoi il sert ici

**L'application ne l'appelle jamais.** La confidentialité est une exigence du projet
(spec §1, §12) : aucun tiers ne doit voir les URL que vous lisez. `curl.md` sert
uniquement **pendant le développement**, comme oracle de comparaison :

> pour une page donnée, comparer le texte extrait par notre `ExtractionService`
> au Markdown renvoyé par `curl.md`.

Un écart entre les deux est un signal : notre extracteur a garde de la navigation,
une publicité ou un bandeau que curl.md a su jeter. Cet écart se traduit par un test
rouge sur une fixture, jamais par un appel réseau dans les tests.

## Corpus

Les URL de référence viennent de `SmartRSS-subscriptions-20261013.xml`, l'export OPML
des abonnements de l'utilisateur. Ces flux servent à indiquer **quels types de sites
l'extracteur doit réussir**, pas à alimenter une fonctionnalité de l'application.

## Limites de l'oracle

- curl.md est lui-même un extracteur : il se trompe aussi, et son rendu Markdown perd
  tout ce que le Markdown ne sait pas représenter (tableaux complexes, figures).
- Il n'est pas une référence absolue. En cas de désaccord, c'est le contenu de la page
  qui tranche, pas le service.
- Ses plans sont payants et son comportement peut changer. Aucun test du dépôt ne doit
  dépendre d'un appel réseau à curl.md.