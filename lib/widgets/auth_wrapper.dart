import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../views/signup-signin/signin.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthenticatedWidget;

  const AuthWrapper({
    super.key,
    required this.child,
    this.loadingWidget,
    this.unauthenticatedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // Show loading widget while checking authentication
        if (authController.isLoading && !authController.isAuthenticated) {
          return loadingWidget ?? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show unauthenticated widget if user is not signed in
        if (!authController.isAuthenticated) {
          return unauthenticatedWidget ?? const SignInView();
        }

        // Show the protected content if user is authenticated
        return child;
      },
    );
  }
}

/// A widget that shows different content based on authentication state
class ConditionalAuthWidget extends StatelessWidget {
  final Widget authenticatedChild;
  final Widget unauthenticatedChild;
  final Widget? loadingChild;

  const ConditionalAuthWidget({
    super.key,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
    this.loadingChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isLoading) {
          return loadingChild ?? const Center(
            child: CircularProgressIndicator(),
          );
        }

        return authController.isAuthenticated
            ? authenticatedChild
            : unauthenticatedChild;
      },
    );
  }
}
