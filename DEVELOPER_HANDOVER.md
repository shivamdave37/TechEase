# TechEase — Developer Handover & Architecture Guide

Welcome to the **TechEase** project! This document contains all the essential architecture details, setup steps, feature checklists, and technical guidelines you need to take over development seamlessly.

---

## 1. Project Overview

**TechEase** is a senior-first smartphone learning, community video sharing, and voice-group messaging application built in Flutter. It is designed specifically for elderly users who need an intuitive, accessible, and respectful way to master digital skills independently.

* **GitHub Repository:** [https://github.com/shivamdave37/design-thinking-](https://github.com/shivamdave37/design-thinking-)
* **Primary Branch:** `master`
* **Live Web App:** [https://shivamdave37.github.io/design-thinking-/](https://shivamdave37.github.io/design-thinking-/)
* **Target Platforms:** Android (Release APK & Google Play ready), Responsive Web (PWA installable on iOS/Android).

---

## 2. Tech Stack & Dependencies

* **Framework:** Flutter 3.50.0 (Dart 3.7.0+)
* **State Management:** `Provider` / `ChangeNotifier` with decoupled reactive services.
* **Audio Engine:** `PlatformAudio` service using modern `package:web` + `dart:js_interop` for browser `MediaRecorder`, `AudioElement`, and `SpeechSynthesis`.
* **Localization:** Custom zero-dependency `LocalizationService` supporting 11 languages in native scripts:
  * English, हिन्दी (Hindi), ગુજરાતી (Gujarati), বাংলা (Bengali), मराठी (Marathi), తెలుగు (Telugu), தமிழ் (Tamil), اردو (Urdu), ಕನ್ನಡ (Kannada), ਪੰਜਾਬੀ (Punjabi), Español (Spanish).
* **Storage / Backend Strategy:**
  * Local-first in-memory persistent service architecture (offline capable).
  * Production Firebase configuration ready in `backend/` (`firestore.rules`, `storage.rules`, schema documentation).
* **Testing:** `flutter_test` suite with 47 unit, widget, and integration tests passing.

---

## 3. Directory Structure

```
elder_smartphone_learning_app/
├── .github/workflows/deploy.yml   # CI/CD: Automated Web deploy to gh-pages + Android APK build
├── assets/
│   ├── data/
│   │   ├── categories.json        # Learning topics, tasks, and step-by-step lessons
│   │   └── glossary.json          # Tech terminology & icon badge explanations
│   └── images/                    # UI illustrations and WhatsApp step mockups
├── backend/                       # Production Firebase rules & schema architecture
│   ├── FIREBASE_ARCHITECTURE.md
│   ├── firestore.rules
│   └── storage.rules
├── lib/
│   ├── app.dart                   # Root MaterialApp with global MediaQuery font scaling
│   ├── design_system.dart         # High-contrast senior design tokens (48dp+ touch targets)
│   ├── main.dart                  # Application entry point
│   ├── models/                    # Data models (Lesson, Task, VoiceGroup, Video, UserProfile)
│   ├── screens/
│   │   ├── auth/                  # Phone OTP login flow (with demo code 1234)
│   │   ├── learn/                 # Home dashboard, category viewer, glossary
│   │   ├── profile/               # Accessibility settings, 11 languages, moderation dashboard
│   │   ├── saved_and_search/      # Multi-attribute search, category chips, bookmarks
│   │   ├── share/                 # QR code & WhatsApp share dialog
│   │   ├── videos/                # Community guide video library, anti-fake certification upload
│   │   ├── voice_groups/          # Asynchronous voice group chat, live recording & preview
│   │   ├── category_screen.dart
│   │   ├── lesson_player_screen.dart # Step progression, Next/Back/Repeat/Confused controls
│   │   ├── practice_screen.dart   # Interactive practice sandbox simulation
│   │   └── main_navigation_shell.dart # Auto-screen adaptation (Laptop Rail vs Mobile BottomBar)
│   ├── services/                  # Reactive business logic (Audio, Auth, Videos, Groups, etc.)
│   └── widgets/                   # Reusable components (ZoomableImageViewer, Dialogs, etc.)
├── test/                          # 47 Unit & Widget tests
│   ├── unit/                      # Models, services, audio abstraction tests
│   ├── widget/                    # Navigation, layout, OTP, and recording widget tests
│   └── widget_test.dart           # End-to-end learning journey test
├── serve.py                       # Local HTTP server script for instant laptop testing
├── start_server.bat               # Windows double-click launcher
├── stop_app.bat                   # Clean server termination script
└── pubspec.yaml                   # Flutter project metadata
```

---

## 4. Quick Start (Run Locally)

### Prerequisites
* Flutter SDK (3.24+ or 3.50+)
* Dart SDK
* Chrome or Edge browser
* Git

### Commands:
```bash
# 1. Clone repository
git clone https://github.com/shivamdave37/design-thinking-.git
cd design-thinking-/elder_smartphone_learning_app

# 2. Install dependencies
flutter pub get

# 3. Run all tests
flutter test

# 4. Run on Chrome
flutter run -d chrome

# 5. Build production web bundle
flutter build web --release
```

---

## 5. Current Feature Status & Audit

| Feature Area | Implementation Status | Notes for Incoming Developer |
|---|---|---|
| **Learning System** | 🟢 100% Complete | 6 categories, step progression, interactive practice sandbox with unlimited retries. |
| **Search & Bookmarks** | 🟢 Complete | Real-time text search, category filter chips, bookmark saving & last unfinished lesson resume. |
| **Voice Groups & Audio** | 🟢 100% Complete | Real microphone recording via `MediaRecorder`, listen-before-send preview, speech playback. |
| **Multi-Language (11)** | 🟢 100% Complete | English, Hindi, Gujarati, Bengali, Marathi, Telugu, Tamil, Urdu, Kannada, Punjabi, Spanish. |
| **Auto-Screen Adaptation** | 🟢 100% Complete | Full-width mobile layout on phones (`<850px`), spacious laptop layout (`>=850px`) with `NavigationRail` and top toolbar. |
| **Global Font Scaling** | 🟢 100% Complete | `MediaQuery.textScaler` physically scales all UI text dynamically across the entire app. |
| **Anti-Fake Guide Hub** | 🟢 100% Complete | Community video upload with mandatory authenticity pledge and `🛡️ Verified Safe Guide` badges. |
| **Phone Number OTP Login** | 🟡 Demo Mode Active | Functional UI with country code picker and demo verification (`1234`). Integrate Twilio or Firebase Phone Auth for live cellular SMS. |
| **Video Player Modal** | 🟡 Control Shell Active | Video player modal renders playback controls. Integrate embedded HTML5 `<video>` or `video_player_web` for hosted `.mp4` streaming. |
| **Cloud Sync** | 🟡 Local-First Ready | Service architecture matches Cloud Firestore 1-to-1. Add `google-services.json` to activate cloud sync across multiple remote devices. |

---

## 6. How CI/CD Deploys

The repository has an automated GitHub Actions workflow in `.github/workflows/deploy.yml`:
1. On every push to `master`, GitHub Actions automatically runs `flutter analyze` and `flutter test`.
2. It builds the Flutter Web release bundle with base href `/design-thinking-/`.
3. It automatically deploys the built web files to the **`gh-pages`** branch.
4. It compiles a release Android APK (`app-release.apk`) and uploads it as a downloadable GitHub Actions artifact.

---

## 7. Contact & Support

If you have questions about architecture choices or need clarification on any module, check:
* `PROJECT_STATUS.md` for historical test results and commits.
* `backend/FIREBASE_ARCHITECTURE.md` for database models and security rules.
