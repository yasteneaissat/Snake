# 🐍 Snake — Version Finale

> Application mobile de jeu Snake développée en Flutter/Dart avec leaderboard en temps réel via Firebase Firestore, dans le cadre du BTS SIO option SLAM — Session 2026.

---

## ⚡ Lancement rapide

```powershell
flutter pub get
flutter run 
```
> Puis choisis **2** pour Chrome dans la liste des appareils.

---

## 📱 Présentation de l'application

SERPENT.EXE est un jeu mobile Snake développé en Flutter/Dart avec une esthétique néon cyberpunk. Le joueur contrôle un serpent qui grandit en mangeant de la nourriture, avec une difficulté croissante au fil des niveaux. Les scores de tous les joueurs sont sauvegardés dans le cloud Firebase Firestore et un classement mondial est accessible en temps réel.

---

## ✨ Fonctionnalités

### 🎮 Jeu
- Serpent contrôlable avec le D-Pad ou les touches fléchées du clavier
- Contrôle également possible par swipe sur écran tactile
- La nourriture apparaît aléatoirement sur la grille
- Le serpent grandit à chaque nourriture mangée
- Nourriture bonus (étoile violette à +50 points) qui apparaît toutes les 3 nourritures et disparaît après 6 secondes
- Système de téléportation : le serpent traverse les bords et réapparaît de l'autre côté
- Si la tête du serpent touche son propre corps, la partie se termine immédiatement

### 🏆 Score et niveaux
- Chaque nourriture rapporte des points selon la difficulté choisie
- Le niveau augmente tous les 5 nourritures mangées
- La vitesse du serpent augmente avec le niveau
- Affichage du score en cours, du niveau et du meilleur score de la session

### ⚙️ Difficultés
- **EASY** — Vitesse lente, multiplicateur x1
- **NORMAL** — Vitesse normale, multiplicateur x2
- **HARD** — Vitesse rapide, multiplicateur x3
- **INSANE** — Vitesse très rapide, multiplicateur x5

### 🎨 Thèmes graphiques
- **Thème Sombre** — Fond noir avec effets néon colorés
- **Thème Clair** — Fond lavande avec serpent rose
- Basculement entre les deux thèmes depuis le menu principal

### 🎵 Sons
- Musique d'ambiance sur le menu
- Musique différente pendant la partie
- Son spécial au Game Over
- La musique se met en pause quand le jeu est en pause

### ⏸️ Pause
- Mise en pause à tout moment avec le bouton dédié ou la touche Espace
- Reprise de la partie là où on s'est arrêté

### 👤 Saisie du nom du joueur
- Avant chaque partie, le joueur saisit son pseudo (2 à 12 caractères)
- Le pseudo apparaît dans le leaderboard global

### 🏆 Leaderboard Firebase
- Les scores sont sauvegardés automatiquement dans Firebase Firestore après chaque partie
- Classement mondial du Top 10 des meilleurs scores
- Mise à jour en temps réel grâce aux Streams Firestore
- Affichage du pseudo, score, niveau, difficulté et date de chaque partie

---

## 🗄️ Base de données

Les scores sont stockés dans **Firebase Firestore** (base de données cloud NoSQL de Google).

### Structure de la collection `scores`

| Champ | Type | Description |
|---|---|---|
| nom | String | Pseudo saisi par le joueur |
| score | Number | Score final obtenu |
| niveau | Number | Niveau atteint lors de la partie |
| difficulte | String | EASY / NORMAL / HARD / INSANE |
| date | Timestamp | Date et heure exacte de la partie |

### Schéma de fonctionnement
```
Joueur saisit son pseudo
        ↓
Choisit la difficulté (Easy / Normal / Hard / Insane)
        ↓
Joue la partie
        ↓
Game Over → Score sauvegardé automatiquement dans Firestore
        ↓
Leaderboard mis à jour en temps réel pour tous les joueurs
```

---

## 🛠️ Environnement technologique

Conformément à l'annexe II.E du référentiel BTS SIO :

| Élément | Outil utilisé |
|---|---|
| Framework applicatif | Flutter SDK 3.x |
| Langages | Dart, YAML, Kotlin |
| SGBD / Base de données | Firebase Firestore (NoSQL cloud) |
| IDE / Environnement de développement | Visual Studio Code |
| Gestion de versions | Git + GitHub |
| Bibliothèque de composants | cloud_firestore, firebase_core, audioplayers |
| Terminal mobile | Google Chrome (web), Android (APK) |
| Accès sécurisé aux données | Règles Firestore (lecture/écriture contrôlées) |

---

## 🔀 Gestion des versions avec Git

Le projet est versionné avec **Git** et hébergé sur **GitHub**.

```
https://github.com/yasteneaissat/snake
```

### Principales étapes de développement

| Version | Description |
|---|---|
| v1.0 | Moteur de jeu Snake de base (serpent, nourriture, collision) |
| v1.1 | Ajout des thèmes sombre et clair |
| v1.2 | Ajout des sons et musiques |
| v1.3 | Intégration Firebase Firestore |
| v1.4 | Ajout du leaderboard en temps réel |
| v2.0 | Version finale — tous les bugs corrigés |

---

## 🧪 Tests réalisés

### Tests fonctionnels

| Test | Résultat |
|---|---|
| Le serpent grandit en mangeant | ✅ Validé |
| Collision avec le corps → Game Over | ✅ Validé |
| Le score s'incrémente correctement | ✅ Validé |
| Le niveau monte tous les 5 nourritures | ✅ Validé |
| La vitesse augmente avec le niveau | ✅ Validé |
| Le bonus apparaît et disparaît | ✅ Validé |
| La pause stoppe le jeu | ✅ Validé |
| La reprise continue la partie | ✅ Validé |
| Le thème bascule correctement | ✅ Validé |
| Le nom du joueur apparaît dans le classement | ✅ Validé |

### Tests d'intégration

| Test | Résultat |
|---|---|
| Connexion à Firebase Firestore | ✅ Validé |
| Écriture d'un score dans la collection `scores` | ✅ Validé |
| Lecture et affichage du Top 10 | ✅ Validé |
| Lancement sur Chrome (web) | ✅ Validé |
| Build APK Android | ✅ Validé |

---

## 📁 Structure du projet

```
snake_game/
├── lib/
│   ├── main.dart          ← Code principal (moteur de jeu + interfaces + thèmes)
│   ├── database.dart      ← Modèle ScoreEntry et service Firestore (ScoreService)
│   └── leaderboard.dart   ← Écran du classement et popup saisie nom joueur
├── assets/
│   └── audio/
│       ├── menu.mp3       ← Musique du menu
│       ├── game.mp3       ← Musique pendant le jeu
│       └── gameover.mp3   ← Musique au Game Over
├── android/
│   └── app/
│       └── google-services.json  ← Configuration Firebase Android
├── web/                   ← Configuration Flutter Web
├── pubspec.yaml           ← Dépendances du projet
└── README.md              ← Documentation
```

---

## 🚀 Lancer l'application

### Sur navigateur Chrome
```powershell
flutter pub get
flutter run -d chrome --web-renderer html
```

### Sur Android
```powershell
flutter build apk --debug
```
> L'APK se trouve dans `build\app\outputs\flutter-apk\app-debug.apk`

---

## 🔥 Configuration Firebase

| Paramètre | Valeur |
|---|---|
| Projet Firebase | serpent-exe |
| Console | https://console.firebase.google.com/project/serpent-exe |
| Collection Firestore | `scores` |
| Règles | Mode test (lecture/écriture ouvertes) |
| Région | europe-west3 |

---

## 📋 Compétences BTS SIO SLAM couvertes

| Compétence | Mise en œuvre dans le projet |
|---|---|
| Concevoir et développer une solution applicative | Développement complet en Flutter/Dart avec architecture multi-fichiers |
| Exploiter les ressources du framework | Utilisation de Flutter (widgets, animations, CustomPainter, Streams) |
| Utiliser des composants d'accès aux données | Firebase Firestore via le package cloud_firestore |
| Gérer les données | Modélisation, écriture et lecture de données dans Firestore |
| Intégrer en continu les versions | Gestion des versions avec Git et GitHub |
| Rédiger la documentation | README complet, commentaires dans le code |
| Réaliser les tests | Tests fonctionnels et d'intégration documentés ci-dessus |

---

*Version finale — BTS SIO SLAM Session 2026 — Aissat Yastene*
