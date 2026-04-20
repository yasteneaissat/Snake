# 🐍 SERPENT.EXE — Version Finale

> Application mobile de jeu Snake développée en Flutter/Dart avec leaderboard en temps réel via Firebase Firestore, dans le cadre du BTS SIO option SLAM.

---

## 📱 Présentation de l'application

SERPENT.EXE est un jeu Snake moderne avec une esthétique néon cyberpunk.
Le joueur contrôle un serpent qui grandit en mangeant de la nourriture.
Les scores de tous les joueurs sont sauvegardés dans le cloud et un classement mondial est accessible en temps réel.

---

## ✨ Fonctionnalités

### 🎮 Jeu
- Serpent contrôlable avec le D-Pad ou les touches fléchées du clavier
- Contrôle également possible par swipe sur écran tactile
- La nourriture apparaît aléatoirement sur la grille
- Le serpent grandit à chaque nourriture mangée
- Nourriture bonus (étoile violette à +50 points) qui apparaît toutes les 3 nourritures et disparaît après 6 secondes
- Système de téléportation : le serpent traverse les bords et réapparaît de l'autre côté
- Si la tête du serpent touche son propre corps, la partie se termine

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
- Avant chaque partie, le joueur saisit son pseudo
- Le pseudo apparaît dans le leaderboard global

### 🏆 Leaderboard Firebase
- Les scores sont sauvegardés automatiquement dans Firebase Firestore après chaque partie
- Classement mondial du Top 10 des meilleurs scores
- Mise à jour en temps réel — le classement se rafraîchit automatiquement sans recharger la page
- Affichage du pseudo, score, niveau, difficulté et date de chaque partie

---

## 🗄️ Base de données

Les scores sont stockés dans **Firebase Firestore** (base de données cloud de Google).

### Structure de la collection `scores`

| Champ | Type | Description |
|---|---|---|
| nom | Texte | Pseudo du joueur |
| score | Nombre | Score final obtenu |
| niveau | Nombre | Niveau atteint |
| difficulte | Texte | EASY / NORMAL / HARD / INSANE |
| date | Date | Date et heure de la partie |

### Fonctionnement
```
Joueur entre son nom
       ↓
Choisit la difficulté
       ↓
Joue la partie
       ↓
Game Over → Score sauvegardé automatiquement dans Firestore
       ↓
Leaderboard mis à jour en temps réel pour tous les joueurs
```

---

## 🛠️ Technologies utilisées

- **Flutter** — Framework de développement mobile cross-platform
- **Dart** — Langage de programmation
- **Firebase Core** — Initialisation de Firebase
- **Cloud Firestore** — Base de données cloud NoSQL en temps réel
- **audioplayers** — Gestion des sons et musiques

---

## 📁 Structure du projet

```
snake_game/
├── lib/
│   ├── main.dart          ← Code principal (moteur de jeu + interfaces)
│   ├── database.dart      ← Modèle de données et service Firestore
│   └── leaderboard.dart   ← Écran du classement et popup nom joueur
├── assets/
│   └── audio/
│       ├── menu.mp3       ← Musique du menu
│       ├── game.mp3       ← Musique du jeu
│       └── gameover.mp3   ← Musique game over
├── android/
│   └── app/
│       └── google-services.json  ← Configuration Firebase Android
└── pubspec.yaml           ← Dépendances du projet
```

---

## ⚡ Lancement rapide — Copier-Coller

```powershell
cd C:\Users\PC\Downloads\snake2\snake_game
flutter pub get
flutter run -d chrome --web-renderer html
```
> Puis choisis **2** pour Chrome dans la liste des appareils.

---



### Sur navigateur Chrome
```bash
flutter pub get
flutter run -d chrome --web-renderer html
```

### Sur Android
```bash
flutter build apk --debug
```
L'APK se trouve dans `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🔥 Configuration Firebase

Le projet est connecté au projet Firebase **serpent-exe**.

- **Console Firebase :** https://console.firebase.google.com/project/serpent-exe
- **Collection Firestore :** `scores`
- **Règles :** Mode test (lecture et écriture ouvertes)

---

## 📋 Différences avec la version bêta

| Fonctionnalité | Version Bêta | Version Finale |
|---|---|---|
| Thème sombre/clair | ❌ Ne fonctionne pas | ✅ Fonctionne |
| D-Pad directionnel | ❌ Gauche/Droite invisibles | ✅ 4 boutons visibles |
| Bouton JOUER | ❌ Trop large | ✅ Taille correcte |
| Sons | ❌ Aucun son | ✅ 3 musiques |
| Pause | ❌ Bloque le jeu | ✅ Pause/Reprise |
| Collision corps | ❌ Serpent traverse | ✅ Game Over correct |
| Score | ❌ Devient négatif | ✅ S'incrémente |
| Niveau | ❌ Reste à 1 | ✅ Monte correctement |
| Leaderboard | ❌ Absent | ✅ Firebase temps réel |
| Sauvegarde scores | ❌ Absent | ✅ Cloud Firestore |

---

*Version finale — BTS SIO SLAM Session 2026*
