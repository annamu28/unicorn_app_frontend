# Unicorn App Frontend

A Flutter-based frontend application for the Unicorn platform, providing a modern and intuitive user interface for managing chatboards, user verification, and attendance tracking.

## Features

- **Chatboard Management**
  - Create and manage chatboards with customizable access controls
  - Role-based access control (Admin, Helper Unicorn, Head Unicorn)
  - Squad and country-based access restrictions

- **User Verification**
  - Pending user approval/rejection system
  - User role management
  - Squad assignment

- **Attendance Tracking**
  - Real-time attendance marking
  - Attendance statistics and reporting
  - Course and lesson management

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/unicorn_app_frontend.git
cd unicorn_app_frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment:
   - Create a `.env` file in the root directory
   - Add necessary environment variables (API endpoints, etc.)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── providers/       # Riverpod providers
├── services/        # API services
├── views/           # UI components
│   ├── chatboard/   # Chatboard related screens
│   ├── panels/      # Feature panels
│   └── tabs/        # Tab views
└── widgets/         # Reusable widgets
```

## Architecture

The application follows a clean architecture pattern with:

- **Riverpod** for state management
- **Go Router** for navigation
- **Dio** for HTTP requests
- **Provider pattern** for dependency injection
