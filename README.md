# Baggagie

A Flutter application built with clean MVC (Model-View-Controller) architecture.

## Project Structure

The project follows the MVC architectural pattern with the following directory structure:

```
lib/
├── models/          # Data models and business logic
│   ├── base_model.dart
│   └── user_model.dart
├── views/           # UI components and screens
│   ├── base_view.dart
│   └── user_list_view.dart
├── controllers/     # Business logic and state management
│   ├── base_controller.dart
│   └── user_controller.dart
├── services/        # External services and API calls
│   ├── base_service.dart
│   └── user_service.dart
├── utils/           # Utility classes and constants
│   └── constants.dart
├── widgets/         # Reusable UI components
│   └── custom_button.dart
└── main.dart        # Application entry point
```

## Architecture Overview

### Models (`lib/models/`)
- **BaseModel**: Abstract base class for all data models
- **UserModel**: Example user data model with JSON serialization

### Views (`lib/views/`)
- **BaseView**: Abstract base class for all views
- **UserListView**: Example view demonstrating user list functionality
- Views are responsible for UI presentation and user interaction

### Controllers (`lib/controllers/`)
- **BaseController**: Abstract base class with common controller functionality
- **UserController**: Example controller managing user-related business logic
- Controllers handle business logic, state management, and coordinate between models and views

### Services (`lib/services/`)
- **BaseService**: Abstract base class for API services
- **UserService**: Example service for user-related API operations
- Services handle external data operations and API calls

### Utils (`lib/utils/`)
- **Constants**: Application-wide constants and configuration

### Widgets (`lib/widgets/`)
- **CustomButton**: Reusable button component
- Custom widgets for consistent UI across the application

## Features

- ✅ Clean MVC architecture
- ✅ Base classes for consistent implementation
- ✅ Error handling and loading states
- ✅ Responsive UI with Material Design 3
- ✅ Mock data service for demonstration
- ✅ User management (CRUD operations)

## Getting Started

1. Ensure you have Flutter installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Dependencies

The project uses the following main dependencies:
- Flutter SDK
- Material Design components
- Provider pattern for state management

## Development Guidelines

- Follow the MVC pattern strictly
- Extend base classes for new functionality
- Keep controllers lightweight and focused
- Use services for external data operations
- Maintain consistent UI patterns using custom widgets

## Future Enhancements

- Add more models and controllers
- Implement real API integration
- Add unit tests for models and controllers
- Implement navigation between different views
- Add local storage and caching
