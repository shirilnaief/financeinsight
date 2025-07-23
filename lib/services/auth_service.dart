import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Auth state
  User? get currentUser => _supabase.currentUser;
  bool get isAuthenticated => _supabase.isAuthenticated;
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  // Sign up
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': 'member',
        },
      );

      if (response.user != null) {
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.error(
            'Sign up failed. Please check your email for verification.');
      }
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign in
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.error('Sign in failed');
      }
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.signOut();
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.resetPassword(email);
      return AuthResult.success(null, message: 'Password reset email sent');
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _supabase
          .select('user_profiles')
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isAuthenticated) return false;

    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .update('user_profiles', updates)
          .eq('id', currentUser!.id)
          .execute();

      return true;
    } catch (e) {
      return false;
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}