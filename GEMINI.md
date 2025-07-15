# GEMINI.md

## Project: borudaruma

**Application Name:** The official application name is 「ボルダルマ」. The name "borudaruma" is used for internal or system-specific identifiers where Japanese characters are not suitable.

**Description:** A new Flutter project.

This document provides guidelines and conventions for developing the `borudaruma` project, with a focus on testing best practices inspired by Takuto Wada.

## Core Technologies & Libraries

- **Framework:** Flutter
- **Routing:** `go_router` for declarative navigation.
- **Local Database:** `isar` for high-performance local data persistence.
- **Image Handling:** `image_picker` for selecting images from the gallery or camera.
- **Utilities:**
  - `uuid`: For generating unique identifiers.
  - `path_provider`: For accessing standard filesystem locations.
  - `package_info_plus`: For retrieving application package information.

## Directory Structure

The project follows a feature-first directory structure:

```
lib/
├── core/          # Core functionalities (e.g., routing, utilities)
│   └── router/
├── features/      # Feature-based modules
│   └── [feature_name]/
│       ├── data/         # Data sources (e.g., repositories)
│       ├── model/        # Data models and entities
│       └── presentation/ # UI (screens, widgets)
├── shared/        # Shared widgets and utilities
│   ├── widgets/     # Common UI components (e.g., CustomButton)
│   └── utils/       # Utility functions
└── main.dart      # Application entry point
```

### Shared Components

- **Shared Widgets:** Reusable UI components that are not specific to a single feature should be placed in `lib/shared/widgets`.
- **Shared Utilities:** Application-wide utility functions or classes should be placed in `lib/shared/utils`.

This approach keeps the `features` directory clean and promotes code reuse.

## Code Generation

This project uses `build_runner` for code generation, primarily for `isar`.

When you modify data models (`*.dart` files annotated with `@collection`), run the following command to regenerate the corresponding `*.g.dart` files:

```sh
dart run build_runner build
```

## Code Style & Linting

This project uses `flutter_lints` to enforce a consistent code style. Ensure your code adheres to the rules defined in `analysis_options.yaml`. You can check your code against these rules by running:

```sh
flutter analyze
```
