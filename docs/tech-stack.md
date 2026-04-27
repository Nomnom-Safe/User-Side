---
marp: true
size: 4:3
paginate: true
title: NomNom Safe Tech Stack
footer: NomNom Safe Tech Stack - Anna Dinius
---

# NomNom Safe Tech Stack

---

## Core Stack

- **Frontend:** Flutter (Dart SDK `^3.9.0`)
- **State Management:** `provider`
- **Backend Services:** Firebase
- **Database:** Cloud Firestore
- **Authentication:** Firebase Authentication

---

## Flutter App Layer

- Built in Flutter with Material design patterns
- Uses `firebase_core` for Firebase initialization
- Uses generated `firebase_options.dart` config
- Uses `url_launcher` for external links (e.g., restaurant websites)

---

## Firebase Layer

- **Auth:** `firebase_auth`
- **Data:** `cloud_firestore`
- **Platform config:** Firebase project config in app and root `firebase.json`
- Data model includes users, businesses/restaurants, menus, menu items, allergens, and addresses

---

## Cloud Functions

- Firebase Cloud Functions in `functions/`
- Runtime: Node.js `22`
- Libraries:
  - `firebase-functions`
  - `firebase-admin`
- Supports deploy, emulator, and logging workflows via npm scripts

---

## Data and Content Tooling

- Firestore data/upload scripts in `firestore/`
- Script languages used:
  - JavaScript
  - Python
- Separate static site in `nomnom-safe-site/`:
  - HTML
  - CSS/SCSS
  - JavaScript

---

## Quality and Testing Stack

- Test levels:
  - Unit
  - Widget
  - Integration
  - E2E
  - Acceptance
  - Regression
- Test tooling:
  - `flutter_test`
  - `integration_test`
  - `fake_cloud_firestore`
  - `mockito`
- Linting:
  - `flutter_lints` (app)
  - `eslint` (functions)
