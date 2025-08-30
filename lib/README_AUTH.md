# Authentication System Documentation

This document explains how to use the Supabase authentication system implemented in the Baggagie app.

## Overview

The authentication system follows clean architecture principles and includes:

- **AuthService**: Handles all Supabase authentication operations
- **AuthController**: Manages authentication state using Provider pattern
- **SignInView**: Login form with validation
- **SignUpView**: Registration form with validation
- **AuthWrapper**: Widget to protect routes and show different content based on auth state
- **HomeScreen**: Example protected screen

## Setup

### 1. Environment Variables

Make sure your `.env` file in `lib/public/assets/` contains:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. Supabase Configuration

The app is already configured to initialize Supabase in `main.dart`. Make sure your Supabase project has:

- Email authentication enabled
- Proper RLS (Row Level Security) policies
- User profiles table (optional, for storing additional user data)

## Usage

### Basic Authentication Flow

1. **Sign In**: Users can sign in with email and password
2. **Sign Up**: New users can create accounts
3. **Password Reset**: Users can reset their passwords via email
4. **Sign Out**: Users can sign out from the app

### Using AuthController

```dart
// Get the auth controller
final authController = Provider.of<AuthController>(context, listen: false);

// Sign in
final success = await authController.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Sign up
final success = await authController.signUp(
  email: 'user@example.com',
  password: 'password123',
  fullName: 'John Doe',
);

// Sign out
await authController.signOut();

// Check authentication state
if (authController.isAuthenticated) {
  // User is signed in
  final user = authController.currentUser;
}
```

### Protecting Routes

Use the `AuthWrapper` widget to protect routes:

```dart
// Protect a route
AuthWrapper(
  child: MyProtectedScreen(),
  loadingWidget: LoadingScreen(),
  unauthenticatedWidget: SignInView(),
)

// Show different content based on auth state
ConditionalAuthWidget(
  authenticatedChild: HomeScreen(),
  unauthenticatedChild: SignInView(),
  loadingChild: LoadingScreen(),
)
```

### Listening to Auth State Changes

The `AuthController` automatically listens to Supabase auth state changes and updates the UI accordingly.

```dart
Consumer<AuthController>(
  builder: (context, authController, child) {
    if (authController.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authController.isAuthenticated) {
      return Text('Welcome ${authController.currentUser?.fullName}');
    }
    
    return Text('Please sign in');
  },
)
```

## Error Handling

The system includes comprehensive error handling:

- **Invalid credentials**: Clear error messages for wrong email/password
- **Email not confirmed**: Prompts user to check email
- **Network errors**: Graceful handling of connection issues
- **Validation errors**: Form validation with helpful messages

## User Model

The `User` model includes:

```dart
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Customization

### Styling

The authentication views use your app's theme. Customize colors, fonts, and layouts in the `ThemeData` configuration in `main.dart`.

### Validation

Form validation can be customized in the signin and signup views. Current validations include:

- Email format validation
- Password minimum length (6 characters)
- Required field validation
- Password confirmation matching

### Additional Features

You can extend the system by:

1. Adding social authentication (Google, Apple, etc.)
2. Implementing biometric authentication
3. Adding user profile management
4. Implementing role-based access control
5. Adding email verification flows

## Security Considerations

- Passwords are handled securely by Supabase
- JWT tokens are managed automatically
- RLS policies should be configured in Supabase
- Never store sensitive data in local storage
- Use HTTPS in production

## Troubleshooting

### Common Issues

1. **"Invalid login credentials"**: Check email/password or user existence
2. **"Email not confirmed"**: User needs to verify email address
3. **Network errors**: Check internet connection and Supabase configuration
4. **Provider not found**: Ensure `MultiProvider` is set up in `main.dart`

### Debug Mode

Enable debug mode in Supabase to see detailed error messages during development.

## Example Implementation

See the `HomeScreen` for an example of how to use the authentication system in a real app screen.
