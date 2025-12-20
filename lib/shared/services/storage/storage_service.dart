import 'package:flutter/foundation.dart';
import 'package:videocalling/core/config/app_variables.dart';

/// Enhanced StorageService with debug logging
class StorageService {
  static dynamic readData({required String key}) {
    final data = box.read(key);

    if (kDebugMode) {
      print("📖 Reading from storage: $key = $data");
    }

    return data;
  }

  static bool checkData({required String key}) {
    final hasData = box.hasData(key);

    if (kDebugMode) {
      print("🔍 Checking if key exists: $key = $hasData");
    }

    return hasData;
  }

  static writeStringData({required String key, required String value}) {
    if (kDebugMode) {
      print("✏️ Writing to storage: $key = $value");
    }

    box.write(key, value);

    // Verify it was saved successfully
    if (kDebugMode) {
      final verification = box.read(key);
      print("✅ Verification - Read from storage: $key = $verification");

      // Add an explicit warning if verification fails
      if (verification != value) {
        print("⚠️ WARNING: Storage write verification failed for $key!");
      }
    }
  }

  static writeBoolData({required String key, required bool value}) {
    if (kDebugMode) {
      print("✏️ Writing bool to storage: $key = $value");
    }

    box.write(key, value);

    // Verify boolean value was saved correctly
    if (kDebugMode) {
      final verification = box.read(key);
      print("✅ Verification - Read bool from storage: $key = $verification");
    }
  }

  static removeData({required String key}) {
    if (kDebugMode) {
      print("🗑️ Removing data from storage: $key");
    }

    box.remove(key);
  }

  /// Utility method to check what's in storage (for debugging)
  static void debugPrintAllStorage() {
    if (!kDebugMode) return;

    try {
      print("📋 ---- STORAGE CONTENTS ---- 📋");

      final allKeys = box.getKeys();
      if (allKeys.isEmpty) {
        print("📭 Storage is empty");
      }

      for (final key in allKeys) {
        final value = box.read(key);
        print("🔑 $key = $value");
      }

      // Also specifically check important keys
      print("\n📍 Important keys:");

      final appLang = box.read(LocalStorageKeys.appLanguage);
      print("🌐 ${LocalStorageKeys.appLanguage} = $appLang");

      final seenOnboarding = box.read(LocalStorageKeys.hasSeenOnboarding);
      print("👀 ${LocalStorageKeys.hasSeenOnboarding} = $seenOnboarding");

      final isLoggedIn = box.read(LocalStorageKeys.isLoggedIn);
      print("🔐 ${LocalStorageKeys.isLoggedIn} = $isLoggedIn");

      final isDoctorLoggedIn = box.read(LocalStorageKeys.isLoggedInAsDoctor);
      print("👨‍⚕️ ${LocalStorageKeys.isLoggedInAsDoctor} = $isDoctorLoggedIn");

      print("📋 -------------------------- 📋");
    } catch (e) {
      print("❌ Error printing storage contents: $e");
    }
  }

  /// Clear all data in storage (for testing)
  static void clearAllStorage() {
    if (kDebugMode) {
      print("🧹 Clearing all storage");
    }
    box.erase();
  }
}

/// Storage keys used throughout the app
class LocalStorageKeys {
  static const String hasSeenOnboarding = "hasSeenOnboarding";
  static const String callSessionCS = "callSessionCS";
  static const String appLanguage = "app_language";
  static const String isBack = "isBack";
  static const String isTokenExist = "isTokenExist";
  static const String token = "token";
  static const String userIdWithAscii = "userIdWithAscii";
  static const String userId = "userId";
  static const String isLoggedIn = "isLoggedIn";
  static const String isLoggedInAsDoctor = "isLoggedInAsDoctor";
  static const String profileImage = "profile_image";
  static const String name = "name";
  static const String phone = "phone";
  static const String email = "email";
  static const String age = "age";
  static const String gender = "gender";
  static const String password = "password";

  /// for video call
  static const String callReceiverName = "receiver_name";
  static const String callReceiverImage = "receiver_image";
  static const String callerImage = "cb_image";
}
