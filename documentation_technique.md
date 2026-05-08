# Scan AI — Documentation Technique

## 1. Services ML Kit utilisés

L'application utilise trois services de **Google ML Kit**, tous exécutés **on-device** (aucun appel réseau nécessaire pour le traitement IA) :

### 1.1 Reconnaissance de texte (OCR)

- **Plugin** : `google_mlkit_text_recognition`
- **Classe** : `TextRecognizer`
- **Fonctionnement** : Reçoit une image (capturée par la caméra ou importée depuis la galerie) via `InputImage.fromFilePath()`, puis extrait tout le texte détecté dans l'image grâce à `processImage()`.
- **Cas d'usage** : L'utilisateur prend une photo d'un document, panneau, ou tout support contenant du texte. Le texte est extrait automatiquement et affiché à l'écran.

### 1.2 Identification de langue

- **Plugin** : `google_mlkit_language_id`
- **Classe** : `LanguageIdentifier`
- **Seuil de confiance** : 0.5 (50 %)
- **Fonctionnement** : Analyse le texte extrait par l'OCR et identifie automatiquement la langue source (ex : français, anglais, arabe, espagnol, allemand).
- **Cas d'usage** : Après l'extraction du texte, la langue est détectée pour configurer correctement le traducteur et informer l'utilisateur.

### 1.3 Traduction on-device

- **Plugin** : `google_mlkit_translation`
- **Classe** : `OnDeviceTranslator`
- **Langues supportées** : Français, Anglais, Arabe, Espagnol, Allemand
- **Fonctionnement** : Traduit le texte extrait de la langue source (détectée automatiquement) vers la langue cible choisie par l'utilisateur. Les modèles de traduction sont téléchargés et exécutés localement sur l'appareil.
- **Cas d'usage** : L'utilisateur sélectionne une langue cible et appuie sur « Traduire » pour obtenir la traduction du texte scanné.

---

## 2. Choix techniques

### 2.1 Plugins utilisés

| Plugin | Version | Rôle |
|--------|---------|------|
| `google_mlkit_text_recognition` | ^0.15.0 | OCR — extraction de texte depuis une image |
| `google_mlkit_language_id` | ^0.10.0 | Détection automatique de la langue du texte |
| `google_mlkit_translation` | ^0.13.1 | Traduction on-device entre langues |
| `image_picker` | ^1.0.0 | Capture photo (caméra) ou sélection depuis la galerie |
| `flutter_tts` | ^3.8.5 | Synthèse vocale (Text-to-Speech) |
| `shared_preferences` | ^2.2.2 | Stockage local clé-valeur (historique, préférences) |
| `provider` | ^6.1.2 | Gestion d'état (thème clair/sombre) |
| `audioplayers` | ^5.2.1 | Lecture de sons de feedback |
| `vibration` | ^2.0.0 | Retour haptique (vibration) |
| `flutter_local_notifications` | ^20.1.0 | Notifications locales et rappels quotidiens |
| `timezone` | ^0.10.1 | Gestion des fuseaux horaires pour les notifications |
| `firebase_core` | ^3.13.0 | Initialisation de Firebase |
| `firebase_auth` | ^5.5.2 | Authentification (email/mot de passe) |
| `cloud_firestore` | ^5.6.6 | Base de données Cloud Firestore (profil utilisateur) |
| `flutter_localizations` | SDK | Support multilingue (FR, EN, AR) |

### 2.2 Widgets et composants clés

| Widget / Composant | Fichier | Description |
|---------------------|---------|-------------|
| `BottomNavBar` | `widgets/bottom_nav_bar.dart` | Barre de navigation personnalisée avec 4 onglets et menu hamburger (profil, déconnexion). Design arrondi avec animation sur l'onglet actif. |
| `CustomAppBar` | `widgets/CustomAppBar.dart` | Barre d'application avec dégradé de couleurs, adaptée au thème clair/sombre. |
| `StreamBuilder<User?>` | `main.dart` | Écoute l'état d'authentification Firebase pour afficher la page de connexion ou l'écran principal. |
| `ChangeNotifierProvider` | `main.dart` | Fournit le `ThemeController` à toute l'arborescence de widgets. |
| `PopupMenuButton` | `bottom_nav_bar.dart` | Menu déroulant déclenché par l'icône hamburger, contenant les options Profil et Déconnexion. |
| `Form` + `TextFormField` | `auth_view.dart` | Formulaire de connexion/inscription avec validation des champs. |

### 2.3 Gestion d'état

- **Provider** : Utilisé pour le thème (`ThemeController` extends `ChangeNotifier`). Le contrôleur notifie les widgets à chaque bascule clair/sombre via `notifyListeners()`.
- **setState** : Utilisé dans `MainScreen` pour la navigation par onglets et le changement de langue, et dans les vues pour les états locaux (chargement, résultats de scan).

### 2.4 Authentification

- **Firebase Auth** : Authentification par email et mot de passe.
- **Cloud Firestore** : Stockage du profil utilisateur (nom, email, date de création) dans la collection `users`, indexé par UID.
- **Auth Gate** : Un `StreamBuilder` dans `main.dart` écoute `authStateChanges()` et bascule automatiquement entre `AuthView` (connexion) et `MainScreen` (application).

### 2.5 Persistance locale

- **SharedPreferences** : Stockage de l'historique des scans sous forme JSON (clé `"history"`), ainsi que les préférences utilisateur (sons de feedback activés/désactivés).

### 2.6 Localisation

- **3 langues supportées** : Français (FR), Anglais (EN), Arabe (AR)
- **Classe `AppText`** : Dictionnaire centralisé de traductions (`Map<String, Map<String, String>>`), accessible via `AppText.get(lang, key)`.
- **Support RTL** : Le changement de locale vers l'arabe applique automatiquement la direction droite-à-gauche via `MaterialApp.locale` et les `localizationsDelegates`.

---

## 3. Structure de l'application

```
lib/
├── main.dart                          # Point d'entrée, initialisation Firebase,
│                                      # Provider, auth gate, configuration thème/langue
│
├── main_screen.dart                   # Écran principal avec navigation par onglets
│                                      # et barre de navigation inférieure
│
├── controllers/
│   ├── scan_controller.dart           # Orchestrateur du flux de scan :
│   │                                  # caméra → OCR → détection langue → traduction → TTS
│   └── theme_controller.dart          # ChangeNotifier pour le basculement clair/sombre
│
├── models/
│   └── scan_result.dart               # Modèle de données (text, language)
│                                      # avec sérialisation JSON
│
├── services/
│   ├── auth_service.dart              # Service Firebase Auth + Firestore
│   │                                  # (connexion, inscription, déconnexion, réinitialisation)
│   ├── ml_service.dart                # Couche d'abstraction ML Kit :
│   │                                  # OCR, détection de langue, traduction, TTS
│   ├── storage_service.dart           # Persistance locale via SharedPreferences
│   │                                  # (historique des scans)
│   ├── feedback_service.dart          # Sons de feedback et vibrations haptiques
│   └── notification_service.dart      # Notifications locales et rappels quotidiens
│
├── views/
│   ├── auth_view.dart                 # Page de connexion / inscription
│   ├── home_view.dart                 # Page d'accueil avec présentation des fonctionnalités
│   ├── scanner_view.dart              # Page principale de scan, traduction et lecture vocale
│   ├── history_view.dart              # Historique des scans avec suppression
│   ├── settings_view.dart             # Paramètres (thème, langue, sons, notifications)
│   └── profile_view.dart              # Page profil utilisateur
│
├── widgets/
│   ├── bottom_nav_bar.dart            # Barre de navigation inférieure personnalisée
│   │                                  # avec menu hamburger
│   └── CustomAppBar.dart              # AppBar réutilisable avec dégradé
│
├── utils/
│   └── app_text.dart                  # Dictionnaire de traductions (FR, EN, AR)
│
assets/
├── sounds/                            # Sons de feedback
└── logoo.jpg                          # Logo de l'application
```

### 3.1 Flux principal de l'application

```
Lancement
  │
  ├── Firebase.initializeApp()
  ├── FeedbackService.init()
  ├── NotificationService.init()
  │
  ▼
Auth Gate (StreamBuilder)
  │
  ├── Non connecté ──► AuthView (Connexion / Inscription)
  │                         │
  │                         ▼
  │                    Firebase Auth
  │                         │
  └── Connecté ────────► MainScreen
                            │
                  ┌─────────┼─────────┬──────────┐
                  ▼         ▼         ▼          ▼
              HomeView  ScannerView  HistoryView  SettingsView
                            │
                  ┌─────────┼─────────┐
                  ▼         ▼         ▼
              Caméra    Galerie    Résultat
                  │         │         │
                  └────┬────┘         │
                       ▼              │
                   OCR (ML Kit)       │
                       ▼              │
                Détection langue      │
                       ▼              │
                  Traduction ◄────────┘
                       ▼
                Synthèse vocale (TTS)
```

### 3.2 Architecture en couches

| Couche | Responsabilité | Fichiers |
|--------|---------------|----------|
| **Vue** | Interface utilisateur, formulaires, affichage | `views/`, `widgets/` |
| **Contrôleur** | Logique métier, orchestration des services | `controllers/` |
| **Service** | Accès aux API (ML Kit, Firebase, stockage, notifications) | `services/` |
| **Modèle** | Structure des données | `models/` |
| **Utilitaire** | Traductions, constantes | `utils/` |
