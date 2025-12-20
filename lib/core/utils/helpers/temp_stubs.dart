// Temporary stub file to replace missing plugins
// This allows the app to compile while we disable certain features

// Stubs for flutter_uploader
enum UploadTaskStatus {
  undefined,
  enqueued,
  running,
  complete,
  failed,
  canceled,
  paused,
}

enum UploadMethod { POST, PUT, PATCH }

class FileItem {
  final String path;

  FileItem({required this.path});
}

class MultipartFormDataUpload {
  final String url;
  final Map<String, String>? headers;
  final List<FileItem>? files;
  final UploadMethod? method;
  final String? tag;

  MultipartFormDataUpload({
    required this.url,
    this.headers,
    this.files,
    this.method,
    this.tag,
  });
}

class FlutterUploader {
  Future<String> enqueue(MultipartFormDataUpload upload) async {
    print('Upload disabled - would upload to: ${upload.url}');
    return 'stub_task_id';
  }

  // Stub progress stream
  Stream<dynamic> get progress => const Stream.empty();

  // Stub result stream
  Stream<dynamic> get result => const Stream.empty();
}

// Stubs for flutter_keyboard_visibility
class KeyboardVisibilityController {
  bool get isVisible => false;

  Stream<bool> get onChange => Stream.value(false);
}

// Stubs for external_path
class ExternalPath {
  static const String DIRECTORY_DOWNLOAD = 'Download';

  static Future<String> getExternalStoragePublicDirectory(
    String directory,
  ) async {
    print('External path disabled - would access: $directory');
    return '/storage/emulated/0/$directory';
  }
}

// Simple stubs to replace ConnectyCube functionality
class CubeChatConnection {
  static CubeChatConnection get instance => CubeChatConnection();

  void destroy() {
    print('Chat connection destroyed');
  }

  void logout() {
    print('Chat logged out');
  }

  bool isAuthenticated() => false;
}

class PushNotificationsManager {
  static PushNotificationsManager get instance => PushNotificationsManager();

  void init() {
    print('Push notifications initialized');
  }

  Future<void> unsubscribe() async {
    print('Push notifications unsubscribed');
  }
}

class SharedPrefs {
  static Future<dynamic> getUser() async => null;
  static Future<void> deleteUserData() async {
    print('User data deleted');
  }
}

Future<void> signOut() async {
  print('User signed out');
}

// Call type constants
class CallType {
  static const int VIDEO_CALL = 1;
  static const int AUDIO_CALL = 2;
}
