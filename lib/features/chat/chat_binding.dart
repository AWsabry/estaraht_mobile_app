import 'package:videocalling/core/config/app_imports.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
          () => ChatController(),
    );
  }
}