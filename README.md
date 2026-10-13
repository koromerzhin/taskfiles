# Taskfiles Collection 🛠️

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

Voir [ENV.md](ENV.md) pour la documentation complète des variables
 d'environnement.

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

## 🔧 Technologies supportées

- **Docker** : Build, Run, Compose, Cleanup

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
