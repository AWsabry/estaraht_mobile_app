import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Custom logger output that sends errors to Firebase Crashlytics
class CrashlyticsOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // Send errors and fatal logs to Crashlytics
    for (var line in event.lines) {
      if (event.level == Level.error || event.level == Level.fatal) {
        FirebaseCrashlytics.instance.log(line);
      }
      // Print to console as well
      print(line);
    }
  }
}

/// Logger instance with stack trace (shows 2 method calls)
/// Automatically logs errors to Firebase Crashlytics
var logger = Logger(printer: PrettyPrinter(), output: CrashlyticsOutput());

/// Logger instance without stack trace (cleaner output)
/// Automatically logs errors to Firebase Crashlytics
var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
  output: CrashlyticsOutput(),
);

/// Initialize Firebase Crashlytics
/// Call this in your main.dart before runApp()
Future<void> initializeCrashlytics() async {
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    loggerNoStack.e(
      'Flutter Error: ${errorDetails.exception}',
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
  };

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    loggerNoStack.e('Async Error: $error', error: error, stackTrace: stack);
    return true;
  };
}

/// Log custom errors to Firebase Crashlytics
void logErrorToCrashlytics(
  dynamic exception,
  StackTrace? stackTrace, {
  String? reason,
  bool fatal = false,
}) {
  FirebaseCrashlytics.instance.recordError(
    exception,
    stackTrace,
    reason: reason,
    fatal: fatal,
  );
  loggerNoStack.e(
    reason ?? 'Error occurred',
    error: exception,
    stackTrace: stackTrace,
  );
}

/// Set user identifier for crash reports
void setCrashlyticsUserId(String userId) {
  FirebaseCrashlytics.instance.setUserIdentifier(userId);
  loggerNoStack.i('Crashlytics user ID set: $userId');
}

/// Add custom key-value pairs to crash reports
void setCrashlyticsCustomKey(String key, dynamic value) {
  FirebaseCrashlytics.instance.setCustomKey(key, value);
}

/// Log a message to Crashlytics (appears in crash reports)
void logToCrashlytics(String message) {
  FirebaseCrashlytics.instance.log(message);
}
