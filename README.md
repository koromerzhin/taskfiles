# Taskfiles Collection 🛠️

[![CI](https://github.com/koromerzhin/taskfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/koromerzhin/taskfiles/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/package-json/v/koromerzhin/taskfiles)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Une collection de scripts Taskfiles réutilisables pour automatiser les tâches
 courantes dans différents types de projets de développement.

## 📋 Vue d'ensemble

Ce projet contient des scripts [Taskfile](https://taskfile.dev/) organisés par
 technologie/framework pour automatiser les tâches répétitives de développement

## 🚀 Installation

### Prérequis

**1. Installer Task** (outil de build moderne alternatif à Make)

***Windows (avec Chocolatey):***

```powershell
    choco install go-task
```

***Windows (avec Scoop):***

```powershell
    scoop install task
```

***Autres méthodes d'installation:*** <https://taskfile.dev/installation/>

**2. Cloner ou copier ce repository** dans votre projet ou dans un dossier
 global

## 📖 Utilisation

### Configuration avec .env

Ce projet supporte l'utilisation de variables d'environnement via un
 fichier `.env` :

**1. Créer le fichier de configuration** :

```bash
    task env:init
```

Consultez `.env.example` (variables documentées) et `task env:show` /
  `task env:validate` pour vérifier votre configuration.

### Utilisation basique

1. **Naviguer dans le dossier de votre projet**
2. **Copier le Taskfile approprié** ou inclure les tâches depuis ce repository
3. **Exécuter les tâches disponibles**

```bash
    # Lister toutes les tâches disponibles
    task --list

    # Exécuter une tâche spécifique
    task nom-de-la-tache
```

## 🔧 Namespaces disponibles

- **docker** : conteneurs, images, stacks Swarm, réseaux, logs, monitoring (`task docker --list-all`)
- **utils** : sauvegardes, nettoyage logs/temp/caches, fichiers, système (`task utils --list-all`)
- **env** : init/validate/show/backup du `.env` (`task env --list-all`)
- **nodejs** : install/init/add-dev-deps (`task nodejs --list-all`)
- **download** : outils PHP `.phar` (`task download --list-all`)
- **apache** : mise à jour config Apache (`task apache --list-all`)
- **lint** : lint YAML/Markdown/Shell/Actions/Docker (`task lint --list-all`)
- **help** : aide détaillée (`task help:default`)

## ⬆️ Migration v1 → v2 (ruptures)

- **docker:create** : plus de défauts personnels — `CONTAINER_NAME` et
  `IMAGE_NAME` sont requis :
  `task docker:create CONTAINER_NAME=mon-conteneur IMAGE_NAME=nginx:latest`
  (avant : `labstag-php` / `koromerzhin/php:8.4.13-apache-symfony` implicites).
- **docker:getfile** : `CONTAINER_NAME` requis ; `DEST_PATH` défaute vers
  `./<container>.env` (plus jamais `./.env`) et l'écrasement d'une
  destination existante exige `FORCE=true` (backup `.bak` automatique) :
  `task docker:getfile CONTAINER_NAME=mon-conteneur DEST_PATH=./.env FORCE=true`.
- **download:php** : `PHP_CODESNIFFER_SHA256` unique remplacée par
  `PHP_CODESNIFFER_PHPCBF_SHA256` + `PHP_CODESNIFFER_PHPCS_SHA256`
  (les deux `.phar` ont des sommes distinctes) ; `phpstan` 1.12.4 → 2.3.1
  et `php-cs-fixer` 3.64.0 → 3.95.27 (surchargeables via `*_VERSION`,
  sommes via `*_SHA256`, recalculables avec `task download:php:checksum`).
- **lint:all** : couvre désormais `yml`, `md`, `shell`, `action` et `docker`
  (prévoir `go` et `python3-yaml` en local, déjà installés par la CI).

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Forker le projet
2. Créer une branche pour votre fonctionnalité
 (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commiter vos changements
 (`git commit -am 'Ajouter une nouvelle fonctionnalité'`)
4. Pousser vers la branche
 (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🔗 Liens utiles

- [Documentation officielle de Task](https://taskfile.dev/)
- [Exemples de Taskfiles](https://github.com/go-task/task/tree/master/docs/docs/usage_examples)
- [Syntaxe YAML](https://yaml.org/spec/1.2/spec.html)

---

**Note :** Ces Taskfiles sont conçus pour être flexibles et adaptables.
 N'hésitez pas à les modifier selon vos besoins spécifiques de projet.
