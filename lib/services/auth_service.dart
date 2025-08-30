import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user session
  static Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Store user data in local storage or state management
        await _storeUserData(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
        emailRedirectTo: null, // Use default redirect URL
      );

      // Note: User will need to confirm email before being able to sign in
      // The response.user will be null until email is confirmed
      if (response.user != null) {
        await _storeUserData(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Clear local user data
      await _clearUserData();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<User?> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      if (response.user != null) {
        await _storeUserData(response.user!);
      }

      return response.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Store user data locally (you can implement this based on your needs)
  static Future<void> _storeUserData(User user) async {
    // Implementation depends on your local storage solution
    // This could be SharedPreferences, Hive, or any other storage
    // For now, we'll just return
  }

  /// Clear user data from local storage
  static Future<void> _clearUserData() async {
    // Implementation depends on your local storage solution
    // For now, we'll just return
  }

  /// Convert Supabase User to our User model
  static app_user.User convertToUserModel(User user) {
    return app_user.User(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }
}
