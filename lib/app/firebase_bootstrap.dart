import 'package:chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

/// Khởi tạo Firebase theo đúng cấu hình mà FlutterFire CLI đã generate.
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError {
    await Firebase.initializeApp();
  } catch (e) {
    // ignore: avoid_print
    print('Error initializing Firebase: $e');
  }
}
