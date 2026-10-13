# Analyse du dépôt `repos/koromerzhin/taskfiles`

- **Chemin analysé** : `repos/koromerzhin/taskfiles` (`/home/koromerzhin/dvp/analyse/repos/koromerzhin/taskfiles`)
- **Date** : 2026-10-13
- **Commit analysé** : `3f7148c` (branche `develop`) — « Revert "chore: remove unused Taskfiles and configuration files" »
- **Outils utilisés** : git (log, status, ls-files), grep, glob, read — lecture seule, aucun `npm install`, aucun appel réseau
- **Note** : ce fichier écrase `analyse/koromerzhin-taskfiles.md` (analyse précédente réalisée alors que HEAD vidait le dépôt ; le code est depuis restauré par le revert).

---

## 1. Projet

**Taskfiles Collection** — bibliothèque de scripts [Task](https://taskfile.dev/) (v3) réutilisables pour automatiser les tâches courantes de développement : gestion Docker / Swarm, sauvegarde, nettoyage, manipulation de fichiers, infos système, gestion du `.env`, projets Node.js, téléchargement d'outils PHP, configuration Apache, linting YAML/Markdown/Actions.

**Technos** : YAML (Taskfile v3) + bash embarqué ; outillage Node.js uniquement pour le lint et la release (`markdownlint-cli`, `yaml-lint`, `release-it`). Runtime requis : `task`, `bash`, `docker` (namespaces docker), `node`/`npm` (lint), `go` (actionlint), `jq` (`task info`).

**Point d'entrée** : `Taskfile.yml` racine (`task default`, `task info`, `task lint:all`, `task validate`, namespaces `docker:`, `utils:`, `env:`, `nodejs:`, `download:`, `help:`, `apache:`, `lint:`).

**Version** : 1.6.3 (`package.json:3`), CHANGELOG généré par `auto-changelog`. Licence MIT (`LICENSE`), remote `https://github.com/koromerzhin/taskfiles.git`.

---

## 2. Architecture

```text
Taskfile.yml                    # racine : dotenv [.env], 8 includes, vars PROJECT_NAME/ENVIRONMENT/TIMESTAMP
├── docker/Taskfile.yml         # create/getfile + 8 sous-namespaces
│   ├── stack/ (772 l.)         # deploy/update/rollback/exec… Swarm
│   ├── monitor/ + monitor/container/
│   ├── images/                 # list/pull/extract/check depuis compose
│   ├── info/ logs/ network/ swarm/ analyze/
├── utils/Taskfile.yml          # 4 sous-namespaces
│   ├── backup/                 # create/list/restore/clean (tar.gz)
│   ├── clean/                  # logs/temp/cache (npm,yarn,docker,composer)
│   ├── file/ (319 l.)          # move/copy/rename/delete avec garde-fous
│   └── system/                 # info/resources/network/performance/env/all
├── env/Taskfile.yml (178 l.)   # init/validate/show/backup du .env
├── nodejs/Taskfile.yml         # install/init/add-dev-deps
├── download/Taskfile.yml       # include php/ uniquement (aucun python/)
│   └── php/ (278 l.)           # tools/update/list/clean, 8 .phar en dur
├── apache/Taskfile.yml         # updateconfig (sed in place)
├── lint/Taskfile.yml           # docker / action / yml / md
├── help/Taskfile.yml           # aide générale + docker + download
├── .github/workflows/ci.yml   # CI : setup task/node/docker + task lint:all
├── package.json / package-lock.json  # devDeps lint + release-it (aucun code JS)
├── .release-it.json / renovate.json / .github/dependabot.yml
├── .env.example / .nvmrc (24) / .gitignore / .whitesource
└── README.md / CHANGELOG.md / LICENSE
```

**Flux principal** : `task <namespace>:<tâche> [VAR=…]` → le Taskfile racine charge `.env` (`Taskfile.yml:5`) puis délègue via `includes:` (`Taskfile.yml:7-15`) ; chaque tâche déclare `desc`/`summary`, des `vars` avec `default`, parfois des `preconditions` (`command -v …`), puis des blocs `cmds:` en bash. Garde-fous typiques : `utils:file:*` (preconditions + confirmation, `utils/file/Taskfile.yml:27-33`), `utils:backup:restore` (confirmation interactive, `utils/backup/Taskfile.yml:119-125`).

**État Git** : branche `develop` (synchro avec `origin/develop`, rien à pousser), copie de travail propre (`git status --porcelain` vide), dernière activité le jour même (`3f7148c`, 2026-10-13 09:50) qui **annule** la suppression massive du commit précédent (`7d9ec32` supprimait les 36 fichiers, +7992/−7992 lignes sur les deux commits). 36 fichiers suivis, ~840 Ko (dominé par `package-lock.json`, 133 Ko). Aucun sous-module, aucun secret versionné, aucun artefact (`node_modules`, `backups`, `.env`) commité.

---

## 3. Points positifs

| # | Point | Preuve |
| --- | ------- | -------- |
| 1 | **Modularité** : 23 Taskfiles en namespaces imbriqués, réutilisables par `includes:` | `Taskfile.yml:7-15`, `docker/Taskfile.yml:3-11` |
| 2 | **Documentation intégrée** : `desc` + `summary` + exemples sur (presque) chaque tâche | `utils/backup/Taskfile.yml:5-19`, `docker/images/Taskfile.yml:10-19` |
| 3 | **Garde-fous** : `preconditions` docker/npm/fichiers, confirmations avant `restore`/`delete`/`clean` PHP | `utils/file/Taskfile.yml:27-33`, `utils/file/Taskfile.yml:296-311` |
| 4 | **CI + Renovate + Dependabot** : lint auto, mises à jour hebdo npm/docker/composer | `.github/workflows/ci.yml`, `renovate.json`, `.github/dependabot.yml` |
| 5 | **Release outillée** : `release-it` + `auto-changelog` + hook `lint:all` pré-release | `.release-it.json:13-16`, `CHANGELOG.md:7-9` |
| 6 | **`.env` ignoré et `.env.example` fourni** : pas de secret commité | `.gitignore:5`, `.env.example:1-28` |
| 7 | **Historique propre et réversible** : le revert `3f7148c` restaure tout, pas de force-push visible | `git log --oneline -3` |

---

## 4. Problèmes

### P0 (cassé ou risqué)

**P0-1 — Backups de secrets non ignorés.** `env:backup` écrit `.env.backup.<timestamp>` (`env/Taskfile.yml:173`) et `utils:backup:create` écrit `backups/*.tar.gz`, mais `.gitignore` ne couvre que `node_modules/` et `.env` (`.gitignore:4-5`). Un `git add -A` commettrait des secrets en clair (le backup `.env` contient les vraies valeurs, et l'archive tar inclut le `.env` du projet). *Correction* : ajouter `.env.backup.*`, `backups/`, `*.tar.gz`, `tools/` au `.gitignore`. *Effort* : S.

**P0-2 — Téléchargement d'exécutables sans vérification d'intégrité.** `curl -L -s -o …` sans `--fail`, sans checksum ni signature, suivi de `chmod +x` (`download/php/Taskfile.yml:117-121`). Une réponse HTTP d'erreur (ou un MITM) produit un `.phar` exécutable corrompu/malveillant ; 8 URLs/versions sont en plus figées en dur (`download/php/Taskfile.yml:4-21`). *Correction* : `curl -fsSL`, épingler les SHA256 attendus en vars et vérifier après téléchargement. *Effort* : M.

**P0-3 — `env:validate` source le `.env` puis `eval` ses variables.** `source "{{.ENV_FILE}}"` exécute du code arbitraire (`env/Taskfile.yml:73-75`), puis `eval "value=\$$var"` (`env/Taskfile.yml:84`) — double injection shell si le fichier est piégé. *Correction* : parser en lecture seule (grep `^VAR=` sans `source`/`eval`). *Effort* : S.

**P0-4 — `apache:updateconfig` destructif et non idempotent.** `sed -ri` écrase sur place sans sauvegarde, avec des vars injectées sans échappement (`&`, `|`, `\` cassent la substitution, `apache/Taskfile.yml:13-15`) ; le bloc `ServerName` est **ajouté à chaque exécution** (`apache/Taskfile.yml:17-23`), donc 2 runs = 2 blocs dupliqués. *Correction* : backup avant écriture, échappement ou `python`/`perl` de templating, garde d'idempotence (`grep -q` avant ajout). *Effort* : S.

**P0-5 — `docker:getfile` écrase `./.env` par défaut sans confirmation.** `DEST_PATH` vaut `"./.env"` (`docker/Taskfile.yml:34-36`) : rapatrier le `.env` d'un conteneur écrase silencieusement le `.env` local (perte de config/secrets locaux). *Correction* : défaut vers `./<container>.env` ou exiger `DEST_PATH`, refuser d'écraser sans `FORCE=true`. *Effort* : S.

### P1 (maintenabilité, dette)

**P1-1 — Compteurs toujours à zéro (bug subshell).** `find … | while read …` fait tourner la boucle en sous-shell : `files_removed`/`total_size` incrémentés puis perdus, le rapport affiche toujours « Aucun fichier » (`utils/clean/Taskfile.yml:42-59` ; même pattern `utils/backup/Taskfile.yml:159-167`). *Correction* : redirection `< <(find …)` (process substitution) ou accumulation via fichier temporaire. *Effort* : S.

**P1-2 — Documentation cassée.** `README.md:47` renvoie vers `ENV.md` inexistant ; `help/Taskfile.yml:21` renvoie vers `USAGE.md` inexistant ; `help/Taskfile.yml:60-74` documente un namespace `download:python` qui n'existe pas (`download/Taskfile.yml:3-5` n'inclut que `php`). Le `README` ne liste que Docker en « Technologies supportées » (`README.md:64-66`) alors qu'il y a 8 namespaces. *Correction* : créer `ENV.md`/`USAGE.md` ou corriger les liens, lister tous les namespaces, supprimer l'aide Python ou ajouter le namespace. *Effort* : S.

**P1-3 — Incohérence de licence et métadonnées vides.** `package.json:12` déclare `ISC` mais `LICENSE` est MIT ; `author` vide (`package.json:10`), `keywords` vides (`package.json:9`). Risque juridique + publication npmGraph confuse. *Correction* : `license: MIT`, renseigner `author`, ou passer en `"private": true` (pas de publication : `npm.publish: false` déjà). *Effort* : S.

**P1-4 — Config Renovate `.nvmrc` inopérante.** Le `regexManager` exige `x.y.z` (`renovate.json:18,35`) et un `matchStrings` ancré sur le littéral `node`, mais `.nvmrc` contient juste `24` (`.nvmrc:1`) : ne matchera jamais, la règle « Update Node.js version » est morte. *Correction* : regex `^(?<currentValue>\d+)$` + `depNameTemplate: node`. *Effort* : S.

**P1-5 — Hook release cassé.** `after:bump: npx auto-changelog -p` (`.release-it.json:15`) mais `auto-changelog` n'est dans aucune `devDependencies` (`package.json:19-23`) ; `before:init` fait `git pull` (`.release-it.json:14`, mutation réseau implicite). *Correction* : déclarer `auto-changelog` en devDep, remplacer `git pull` par un contrôle `git fetch --dry-run` / statut propre. *Effort* : S.

**P1-6 — `nodejs:add-dev-deps` non déterministe.** Var `DEV_DEPS` déclarée (`nodejs/Taskfile.yml:5`) mais ignorée au profit d'une liste codée en dur de 11 paquets **sans versions** (`nodejs/Taskfile.yml:39`), installés un par un (`nodejs/Taskfile.yml:48-53`) → churn de `package.json`/`package-lock.json` à chaque run. *Correction* : utiliser la var, épingler les versions, une seule passe `npm install --save-dev`. *Effort* : S.

**P1-7 — Tâches racine incomplètes/fragiles.** `task info` appelle `jq` sans `preconditions` (`Taskfile.yml:48`) et oublie `apache`/`lint`/`help` dans les namespaces listés (`Taskfile.yml:55-59`) ; `task validate` ne vérifie que le `.env` (`Taskfile.yml:71-74`), pas le lint ; `lint:all` ne couvre que `yml+md` (`Taskfile.yml:39-41`), pas `action`/`docker`. *Correction* : preconditions `jq`, liste exhaustive, `validate: lint:all + env:validate`. *Effort* : S.

**P1-8 — Valeurs par défaut personnelles codées en dur.** `docker:create` défaut `labstag-php` / `koromerzhin/php:8.4.13-apache-symfony` (`docker/Taskfile.yml:22-23`) : inadapté à une collection générique. *Correction* : défauts neutres (`my-container`, image à fournir, erreur claire si absente). *Effort* : S.

**P1-9 — CI perfectible.** `actions/cache@v6` redondant avec `cache: npm` de `setup-node` (`.github/workflows/ci.yml:28-39`) ; `npm install` conditionnel (`ci.yml:43-45`) fige un `node_modules` potentiellement périmé issu du cache ; actions épinglées en majeur (`@v7`, `@v2`) sans SHA ; `task lint:all` ne couvre ni les workflows ni le compose. *Correction* : un seul mécanisme de cache, `npm ci`, pin SHA + Renovate, `lint:all` élargi. *Effort* : M.

**P1-10 — Reproductibilité faible.** `.nvmrc` = `24` flottant (`.nvmrc:1`), devDeps en plages (`0.49.*`, `21.1.*`, `1.7.*`, `package.json:20-22`), `go install …@latest` (`lint/Taskfile.yml:25`) et `npx` non épinglés, aucune config `.markdownlint` / yamllint. *Correction* : `.nvmrc` en `24.x.y`, versions exactes + `npm ci`, pin `actionlint`, ajouter les configs de lint. *Effort* : M.

**P1-11 — Dependabot bruyant.** Écosystèmes `docker` et `composer` scannés à `/` (`dependabot.yml:13-29`) alors qu'il n'y a ni `docker-compose.yml` ni `composer.json` : bruit hebdomadaire sans valeur. *Correction* : les retirer tant qu'aucun manifeste n'existe. *Effort* : S.

**P1-12 — Versions d'outils PHP figées et datées.** `phpstan 1.12.4` (branche 2.x sortie), `php-cs-fixer 3.64.0`, `phpmd 2.15.0`, `codesniffer 3.7.2` (`download/php/Taskfile.yml:14-21`) + `cd ..` fragile supposé sur la profondeur d'inclusion (`download/php/Taskfile.yml:54,185,253`). *Correction* : versions en vars surchargeables + résolution de racine via `{{.TASKFILE_DIR}}`/`GIT_ROOT`. *Effort* : M.

### P2 (confort)

**P2-1 — Aucun test.** Logique bash complexe (tar, find, curl, sed) sans `bats`/`shellcheck` ni job CI. *Effort* : M.

**P2-2 — Parsing fragile des images Docker.** `grep -E "^\s*image:"` + `sed` (`docker/images/Taskfile.yml:33,69,120,149`) casse sur ancres YAML/multiligne ; `yq` optionnel seulement à l'extraction. *Effort* : S.

**P2-3 — `utils:system:network` fait du réseau.** `ping 8.8.8.8` et `ping github.com` (`utils/system/Taskfile.yml:98-108`) : lent/bloquant hors-ligne et derrière proxy. *Effort* : S (timeout + désactivable).

**P2-4 — Portabilité macOS/Windows.** `realpath` absent de macOS par défaut (`utils/file/Taskfile.yml:42,130,217`), `stat -f/-c` et `numfmt` déjà bricolés mais fragiles (`utils/clean/Taskfile.yml:44-45`), `read -p -n 1` bloque en CI non-TTY (`download/php/Taskfile.yml:271`, `utils/backup/Taskfile.yml:120`). *Effort* : M.

**P2-5 — `.whitesource` à moitié configuré.** `baseBranches: []` vide (`.whitesource:3`) : périmètre de scan Mend indéfini. *Effort* : S.

**P2-6 — `CHANGELOG.md` exclu du lint sans justification** (`lint/Taskfile.yml:79`) et `.env.example:6` (`PROJECT_VERSION=1.0.0`) désynchronisé de `package.json` (1.6.3). *Effort* : S.

**P2-7 — Pas de `schema` Taskfile ni badges/CONTRIBUTING.** Autocomplétion IDE absente, README sans statut CI/version/licence. *Effort* : S.

---

## 5. Manques

| Manque | Gravité | Détail |
| -------- | --------- | -------- |
| `.gitignore` couvrant backups/archives/outils | **bloquant** | P0-1 : risque de committer des secrets |
| Vérification d'intégrité des `.phar` (SHA256) | **bloquant** | P0-2 : chaîne d'approvisionnement |
| Tests (`bats`) + `shellcheck` en CI | **important** | P2-1 : bash complexe non vérifié |
| Configs `markdownlint` / `yaml-lint` versionnées | **important** | P1-10 : lint non reproductible |
| Doc d'inclusion dans un projet tiers (remote `includes:`) | **important** | P1-2 : adoption impossible sans lire le code |
| `CONTRIBUTING.md` + badges README | souhaitable | P2-7 |
| `taskfile-schema.json` / config VS Code | souhaitable | P2-7 |
| Nettoyage `.env` de démo post-CI (`cp .env.example .env` en CI sans suppression) | souhaitable | `.github/workflows/ci.yml:47-49` |

---

## 6. Mises à jour proposées

| Priorité | Action | Fichiers concernés | Effort | Dépend de |
| ---------- | -------- | -------------------- | -------- | ----------- |
| P0 | Étendre `.gitignore` (`.env.backup.*`, `backups/`, `*.tar.gz`, `tools/`, `docker-images.txt`) | `.gitignore` | S | — |
| P0 | `curl -fsSL` + SHA256 épinglés et vérifiés avant `chmod +x` | `download/php/Taskfile.yml` | M | — |
| P0 | `env:validate` sans `source`/`eval` (parse passif) | `env/Taskfile.yml` | S | — |
| P0 | `apache:updateconfig` : backup, échappement, idempotence | `apache/Taskfile.yml` | S | — |
| P0 | `docker:getfile` : ne plus défauter vers `./.env`, garde anti-écrasement | `docker/Taskfile.yml` | S | — |
| P1 | Corriger le bug subshell des compteurs (`< <(find…)`) | `utils/clean`, `utils/backup` | S | — |
| P1 | Réparer README/help (liens, namespaces, python) | `README.md`, `help/Taskfile.yml` | S | — |
| P1 | Aligner licence (`MIT`), `author`, `private: true` | `package.json` | S | — |
| P1 | Réparer le regexManager `.nvmrc` Renovate | `renovate.json` | S | — |
| P1 | Déclarer `auto-changelog`, retirer `git pull` du hook | `.release-it.json`, `package.json` | S | — |
| P1 | `add-dev-deps` déterministe (versions épinglées, 1 passe) | `nodejs/Taskfile.yml` | S | — |
| P1 | `info`/`validate`/`lint:all` exhaustifs + precondition `jq` | `Taskfile.yml` | S | — |
| P1 | Défauts `docker:create` neutres | `docker/Taskfile.yml` | S | lot P0 getfile |
| P1 | CI : `npm ci`, un seul cache, pins SHA, lint élargi | `.github/workflows/ci.yml` | M | lot lint |
| P1 | Reproductibilité : `.nvmrc` exact, pins, configs lint | `.nvmrc`, `package.json`, `lint/`, `package-lock.json` | M | lot CI |
| P1 | Retirer `docker`/`composer` de Dependabot (ou ajouter les manifestes) | `.github/dependabot.yml` | S | — |
| P1 | Versions PHP en vars + racine robuste | `download/php/Taskfile.yml`, `.env.example` | M | lot P0 curl |
| P2 | Suite `bats` + `shellcheck` en CI | nouveau `test/`, `.github/workflows/ci.yml` | M | lots P0/P1 shell |
| P2 | `yq`-first pour les images, fallback grep documenté | `docker/images/Taskfile.yml` | S | — |
| P2 | `system:network` avec timeouts + opt-out | `utils/system/Taskfile.yml` | S | — |
| P2 | Portabilité (`realpath` fallback, pas de `read -p` bloquant en CI) | `utils/file`, `utils/backup`, `download/php` | M | — |

---

## 7. Plan d'action

### Lot 1 — Secrets et sécurité (P0), ~1 h

1. Étendre `.gitignore` puis vérifier : `git status --porcelain --ignored | grep -E 'backups|tools|tar.gz|backup'` ne doit rien lister de suivi.
2. `download/php` : `curl -fsSL`, SHA256 en vars, `sha256sum -c` avant `chmod +x`.
3. `env:validate` : remplacer `source`+`eval` par `grep -E '^[A-Z_]+='`.
4. `apache:updateconfig` : `cp --backup`, échappement `sed`, `grep -q ServerName` avant ajout (relancer 2× → `git diff` vide la 2ᵉ fois).
5. `docker:getfile` : défaut `DEST_PATH` hors `.env`, refus d'écrasement sans `FORCE=true`.
*Vérification* : `git status --porcelain` propre ; `task env:validate` OK sur `.env.example` ; rejouer chaque tâche 2 fois sans dérive.

### Lot 2 — Dette fonctionnelle (P1 shell), ~2 h

1. Compteurs subshell (`clean`, `backup:clean`) → process substitution ; tester avec de vrais vieux logs.
2. README/help : liens morts supprimés, 8 namespaces documentés, aide Python retirée ou namespace créé.
3. `package.json` (licence MIT, author, `private`), Renovate `.nvmrc`, `auto-changelog` déclaré, `add-dev-deps` épinglé, `info`/`validate`/`lint:all` exhaustifs, défauts docker neutres.
*Vérification* : `task --list-all` cohérent avec le README ; `npx release-it --dry-run` sans erreur de hook.

### Lot 3 — CI et reproductibilité (P1 CI), ~2 h

1. `npm ci`, suppression du cache redondant, pins SHA des actions, `lint:all` incluant `action`+`docker`.
2. `.nvmrc` exact, devDeps exactes (`npm install --save-exact`), configs `markdownlint`/`yamllint` commitées.
3. Dependabot réduit à `npm` (ou manifestes ajoutés).
*Vérification* : workflow vert sur branche de test ; `npm ci --dry-run` reproductible ; `task lint:all` couvre `.github/` et le compose.

### Lot 4 — Qualité durable (P2), ~0,5–1 j

1. `bats` : 3 tests min (`env:validate`, `backup:create/restore`, `clean:logs` avec bug P1-1 en non-régression) + `shellcheck` en CI.
2. `yq`-first, `system:network` non bloquant, fallbacks portabilité, `baseBranches: [main/develop]` dans `.whitesource`, badges + CONTRIBUTING + schéma Taskfile.
*Vérification* : `task test` vert en local et en CI ; README affichant statuts.

---

## 8. Limites de l'analyse

- **Lecture seule stricte** : aucune exécution (`task`, `shellcheck`, `bats`, `npm ci`) — les bugs P1-1/P0-4 sont établis par lecture du code, non par reproduction.
- **Aucune vérification réseau** : disponibilité de `ubuntu-26.04` sur GitHub-hosted, existence des tags d'actions `@v7`/`@v2`, vulnérabilités npm (`npm audit` non lancé en mode audit, volontairement) et fraîcheur réelle des versions `.phar` non contrôlées.
- **Lecture partielle** : `docker/stack/Taskfile.yml` (772 l., 80 premières lues), `docker/monitor*.yml`, `docker/logs|network|swarm|info|analyze` non inspectés ligne à ligne — d'autres problèmes peuvent s'y cacher.
- **Hypothèse Bash/Linux** : la portabilité est jugée sur les idiomes, sans matrice de test macOS/Windows/Alpine.

---

## Historique des analyses

- 2026-10-13 — commit `3f7148c` (develop) — 5 P0 / 12 P1 / 7 P2 (présente analyse, code restauré par revert)
- 2026-10-13 — commit `7d9ec32` — 2 P0 / 4 P1 / 5 P2 (analyse sur HEAD~1 `6f2e824` : dépôt vidé en HEAD, P0 « dépôt vidé » depuis résolu par le revert `3f7148c`)
