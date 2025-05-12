# Jeu Toro et Vache

Un jeu de déduction numérique développé avec Flutter par Bensalah Hamza.

## Description du jeu

Toro et Vache est un jeu où le joueur doit deviner un nombre secret à 4 chiffres. Après chaque tentative, le jeu donne deux types d'indices :
- 🎯 **TORO** : Le nombre de chiffres corrects et bien placés
- 🐮 **VACHE** : Le nombre de chiffres corrects mais mal placés

### Règles
- Le nombre secret contient 4 chiffres différents
- Le premier chiffre ne peut pas être 0
- Chaque chiffre ne peut être utilisé qu'une seule fois

### Fonctionnalités
- Système de score et de record
- Historique des parties jouées
- Interface intuitive avec clavier numérique
- Sauvegarde des meilleurs scores

## Technologies utilisées
- Flutter
- Shared Preferences pour la persistance des données
- Animations Lottie

## Installation
```bash
flutter pub get
flutter run
```

## Contribution
Développé par Bensalah Hamza
