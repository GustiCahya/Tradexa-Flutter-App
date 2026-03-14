# 📊 Tradexa Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-blue?style=flat&logo=riverpod&logoColor=white)](https://riverpod.dev)
[![Isar](https://img.shields.io/badge/Isar-Database-764ABC?style=flat)](https://isar.dev)
[![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean-green?style=flat)](https://en.wikipedia.org/wiki/Clean_architecture)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Tradexa** is a high-performance, offline-first trading journal application built with Flutter. It's designed to provide traders with a "zero-loading" experience, leveraging local persistence and reactive state management.

## 🚀 Key Features

-   **Zero-Loading UX**: Instant access to trading data via Isar local persistence.
-   **Offline-First**: Full functionality without an internet connection.
-   **Silent Background Sync**: Background data synchronization via Dio.
-   **Advanced State Management**: Robust and reactive state handling using Riverpod.
-   **Deep Analytics**: Interactive summary and performance metrics (PNL, Win Rate, RR).
-   **Modern UI**: Sleek dark mode design with `Lucide Icons` and custom animations.

## 🛠️ Tech Stack

-   **Frontend**: Flutter (Mobile/Web/Desktop support)
-   **State Management**: [Riverpod](https://riverpod.dev) (using code generation)
-   **Local Database**: [Isar](https://isar.dev) (High-speed NoSQL)
-   **Networking**: [Dio](https://pub.dev/packages/dio) for robust API communication
-   **Routing**: [GoRouter](https://pub.dev/packages/go_router)
-   **UI Enhancement**: 
    -   `lucide_icons` for modern iconography.
    -   `flutter_animate` for smooth transitions.
    -   `fl_chart` for data visualization.
    -   `google_fonts` for premium typography.

## 🏗️ Architecture

The app follows a **Repository Pattern** combined with **Clean Architecture** principles to separate concerns and ensure testability:

1.  **Entities/Models**: Isar-annotated models for local storage and JSON serialization.
2.  **Repositories**: Abstraction layer managing data flow between Isar and Remote API.
3.  **Providers**: Riverpod `AsyncNotifier`s and `Provider`s for reactive state.
4.  **UI**: Consumer widgets that automatically react to state changes.

## 🏁 Getting Started

### Prerequisites

-   Flutter SDK (^3.11.1)
-   Android Studio / VS Code

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/GustiCahya/Tradexa-Flutter-App.git
    ```
2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate code (for Riverpod/Isar):**
    ```bash
    dart run build_runner build -d
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

