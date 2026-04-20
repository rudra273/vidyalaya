# Vidyālaya

**Vidyālaya** is a modern, feature-rich educational platform designed specifically for Indian school students. Focused on accessibility and ease of use, it serves as a digital companion for students to access textbooks, manage their study schedules, and organize their learning materials—all in one place.

---

## ✨ Features

- **📚 Digital Library**: Access a wide range of school textbooks (SCERT Odisha) directly within the app.
- **📖 PDF Reader**: Read books with a smooth, optimized PDF viewer.
- **📥 Offline Mode**: Download books once and read them anytime, anywhere, without an internet connection.
- **📅 Timetable Management**: Keep track of your daily classes and periods with a dedicated scheduler.
- **📝 Smart Notes**: Organize your thoughts and study notes by subject.
- **🔖 Bookmarks**: Quickly save important pages and sections to revisit later.
- **🌓 Dynamic Themes**: Choose between a vibrant light mode and a high-contrast, eye-friendly dark mode.
- **🎓 Personalized Experience**: Select your specific class and medium to get tailored content.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive & Testable)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router) (Declarative navigation)
- **Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences) (Local settings)
- **File Handling**: [Path Provider](https://pub.dev/packages/path_provider) & `http` (Downloads & Caching)
- **Typography**: [Google Fonts](https://fonts.google.com/) (Inter, Roboto, etc.)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- An Android device or emulator (API level 21+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rudra273/vidyalaya.git
   cd vidyalaya
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🔒 Privacy Policy

We value student privacy. Vidyālaya is designed to be a safe educational environment.
- **No Data Collection**: We do not store or transmit any personal data to external servers.
- **Local Storage**: All your preferences and bookmarks stay on your device.

You can read our full [Privacy Policy here](https://rudra273.github.io/vidyalaya/privacy_policy.html) (or locally in the `docs/` folder).

---

## 🗺️ Project Structure

```text
lib/
├── app/          # Navigation and Global Themes
├── data/         # Models and Seed Data
├── providers/    # Riverpod state management
├── screens/      # Feature-specific UI screens
├── widgets/      # Shared reusable components
└── main.dart     # Entry point
```

---

## 📜 License

Created with ❤️ by [Your Name/Team].
Distributed under the MIT License. See `LICENSE` for more information.
