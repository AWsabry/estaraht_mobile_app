import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load from .env
String get APP_ID => dotenv.env['VIDEO_CALL_APP_ID'] ?? '';
String get AUTH_KEY => dotenv.env['VIDEO_CALL_AUTH_KEY'] ?? '';
String get AUTH_SECRET => dotenv.env['VIDEO_CALL_AUTH_SECRET'] ?? '';
String get ACCOUNT_ID => dotenv.env['VIDEO_CALL_ACCOUNT_ID'] ?? '';
String get DEFAULT_PASS => dotenv.env['VIDEO_CALL_DEFAULT_PASS'] ?? '';
