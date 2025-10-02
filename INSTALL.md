# Script d'installation et de démonstration

## Installation de Task

### Windows (PowerShell en tant qu'administrateur)

```powershell
# Avec Chocolatey
choco install go-task

# Avec Scoop
scoop install task

# Installation manuelle
$version = "v3.31.0"
$url = "https://github.com/go-task/task/releases/download/${version}/task_windows_amd64.zip"
Invoke-WebRequest -Uri $url -OutFile "task.zip"
Expand-Archive "task.zip" -DestinationPath "."
Move-Item "task.exe" "C:\Windows\System32\"
Remove-Item "task.zip"
```

### Linux/macOS

```bash
# Avec package manager
brew install go-task/tap/go-task  # macOS
sudo snap install task --classic  # Ubuntu

# Installation manuelle
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d
```

## Test de base

Une fois Task installé, vous pouvez tester avec :

```bash
# Dans le dossier taskfiles
task --list

# Afficher l'aide
task
```

## Utilisation dans vos projets

### 1. Copie directe

Copiez le Taskfile approprié dans votre projet :

```bash
# Pour un projet Laravel
cp php/laravel/Taskfile.yml mon-projet-laravel/

cd mon-projet-laravel
task install  # Installation des dépendances
task serve    # Démarrage du serveur
```

### 2. Variables d'environnement

Créez un fichier `.env` pour personnaliser les variables :

```env
# .env
DB_HOST=localhost
DB_NAME=mon_projet
PACKAGE_MANAGER=yarn
PORT=8080
```

## Personnalisation

Vous pouvez facilement personnaliser les Taskfiles pour vos besoins :

1. **Variables** : Modifiez les variables par défaut
2. **Commandes** : Ajoutez vos propres commandes
3. **Conditions** : Utilisez les conditions pour adapter le comportement
4. **Includes** : Combinez plusieurs Taskfiles

## Intégration IDE

### VS Code

Installez l'extension "Task" pour VS Code pour une intégration complète.

### PhpStorm/WebStorm

Configurez les outils externes pour utiliser Task comme runner de tâches.

## Bonnes pratiques

1. **Versioning** : Versionnez vos Taskfiles avec votre projet
2. **Documentation** : Documentez vos tâches personnalisées
3. **Variables** : Utilisez des variables pour la flexibilité
4. **Modularité** : Séparez les tâches par domaine fonctionnel
5. **Tests** : Testez vos Taskfiles régulièrement

## Support et contribution

- Documentation officielle : https://taskfile.dev/
- Issues et suggestions : Créez une issue dans le repository
- Contributions : Fork et Pull Request welcome !