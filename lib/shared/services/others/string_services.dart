import 'package:videocalling/core/config/app_imports.dart';

class StringChangeNotifier {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get stringStream => _controller.stream;

  void updateString(String newValue) {
    _controller.add(newValue);
  }

  void dispose() {
    _controller.close();
  }
}
