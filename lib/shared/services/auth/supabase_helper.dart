import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/utils/logger.dart';

/// Global Supabase helper class to access Supabase client and user throughout the app
class SupabaseHelper {
  // Singleton pattern
  static final SupabaseHelper _instance = SupabaseHelper._internal();
  factory SupabaseHelper() => _instance;
  SupabaseHelper._internal();

  /// Get Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  /// Convenient method to access tables directly (same as client.from())
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Get auth instance
  GoTrueClient get auth => client.auth;

  /// Get current authenticated user
  User? get currentUser {
    final user = client.auth.currentUser;
    // Only log when explicitly needed, not on every access
    return user;
  }

  /// Get current user ID (with logging for debugging)
  String? get currentUserId {
    final user = currentUser;
    if (user != null) {
      return user.id;
    }
    return null;
  }

  /// Get current user email
  String? get currentUserEmail {
    return currentUser?.email;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    final authenticated = currentUser != null;
    return authenticated;
  }

  /// Get current session
  Session? get currentSession {
    return client.auth.currentSession;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return client.auth.onAuthStateChange;
  }

  /// Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      loggerNoStack.i('Refreshing session...');
      final response = await client.auth.refreshSession();
      loggerNoStack.i('✅ Session refreshed successfully');
      return response;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error refreshing session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get user metadata
  Map<String, dynamic>? get userMetadata {
    return currentUser?.userMetadata;
  }

  /// Get current user with session refresh if needed
  Future<User?> getCurrentUserWithRefresh() async {
    try {
      // First try to get current user
      var user = client.auth.currentUser;

      if (user != null) {
        loggerNoStack.d('✅ User already authenticated: ${user.id}');
        return user;
      }

      // If no user, try to refresh the session
      loggerNoStack.i('No current user, attempting to refresh session...');

      final session = client.auth.currentSession;
      if (session != null) {
        loggerNoStack.i('Session exists, refreshing...');
        final response = await client.auth.refreshSession();
        if (response.user != null) {
          loggerNoStack.i('✅ Session refreshed successfully');
          return response.user;
        }
      }

      loggerNoStack.w('⚠️ No authenticated user and no session to refresh');
      return null;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error getting user with refresh: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Print current user info (for debugging)
  void printUserInfo() {
    final user = currentUser;
    if (user != null) {
      loggerNoStack.i('=== Current User Info ===');
      loggerNoStack.i('ID: ${user.id}');
      loggerNoStack.i('Email: ${user.email}');
      loggerNoStack.i('Created At: ${user.createdAt}');
      loggerNoStack.i('Last Sign In: ${user.lastSignInAt}');
      loggerNoStack.i('Metadata: ${user.userMetadata}');
      loggerNoStack.i('========================');
    } else {
      loggerNoStack.w('No user is currently authenticated');
    }
  }

  /// Verify and log session after login
  void verifySession() {
    final user = currentUser;
    final session = currentSession;

    loggerNoStack.i('=== Session Verification ===');
    if (user != null && session != null) {
      loggerNoStack.i('✅ User authenticated: ${user.id}');
      loggerNoStack.i('✅ Session active');
      loggerNoStack.i(
        '✅ Access token present: ${session.accessToken.isNotEmpty}',
      );
      loggerNoStack.i(
        'Session expires at: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : 'N/A'}',
      );
    } else {
      loggerNoStack.e('❌ No active session found');
      if (user == null) loggerNoStack.e('  - No user');
      if (session == null) loggerNoStack.e('  - No session');
    }
    loggerNoStack.i('===========================');
  }
}

/// Global instance for easy access
final supabaseHelper = SupabaseHelper();
