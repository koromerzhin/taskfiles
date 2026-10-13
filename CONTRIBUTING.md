# Contribuer

## Flux de contribution

1. Forker le projet puis créer une branche (`git checkout -b feature/ma-fonctionnalite`).
2. Faire vos changements en respectant les conventions ci-dessous.
3. Vérifier en local avant de pousser :
   - `task lint:all` (doit être vert, `CHANGELOG.md` auto-généré exclu)
   - `task validate` (`lint:all` + `env:validate`)
   - `task --list-all` reste cohérent avec `README.md` et `task help:<namespace>`
4. Ouvrir une Pull Request vers `develop` (la release se fait depuis `main` via `release-it`).

## Conventions Taskfile

- Chaque tâche expose `desc` + `summary` (variables et exemples d'usage).
- Dépendances outils via `preconditions` (`command -v …`) avec message clair, jamais d'échec obscur.
- Rétrocompatibilité : ne jamais changer un défaut (`DEST_PATH`, `CONTAINER_NAME`, …) ni une signature sans passage en version majeure ; préférer vars additive avec défaut identique à l'ancien comportement.
- Sécurité shell :
  - ne jamais `source`/`eval` un fichier (parser en lecture seule, ex. `env:validate`) ;
  - `curl -fsSL` (jamais `-s` seul) avant tout `chmod +x` ;
  - toute écriture destructive fait un backup d'abord (`.bak`/horodaté) et reste idempotente (2ᵉ run = no-op) ;
  - toute confirmation `read -p` supporte `FORCE=true` et échoue vite en non-interactif (`[ ! -t 0 ]`).
- Parsing : `yq`-first avec fallback `grep` documenté ; pas de `find … | while` (subshell) — rediriger la boucle.
- Réseau : tout appel réseau a un timeout court et un opt-out (`SKIP_…=true`).
- Secrets : ne jamais committer `.env`, backups (`*.bak`, `.env.backup.*`, `backups/`) ou archives — voir `.gitignore`.

## Release

- Réservée aux mainteneurs sur `main` : `npm run release` (`release-it`, `publish: false`, `CHANGELOG.md` via `auto-changelog`).
- Le hook `before:init` ne fait aucune mutation (`git fetch --dry-run` + `task lint:all`).
