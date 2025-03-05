import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/firebaseHelper.dart';
import 'package:chat_app/models/userModel.dart';
import 'package:chat_app/pages/Home-Page.dart';
import 'package:chat_app/pages/Main-Page.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();

//   var box = await Hive.openBox("mybox");
//   await Firebase.initializeApp();
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   if (currentUser != null) {
//     //Logged In
//     UserModel? thisUserModel =
//         await FirebaseHelper.getUserModelById(currentUser.uid);
//     runApp(MyLoggedApp(
//       firebaseUser: currentUser,
//       userModel: thisUserModel!,
//     ));
//   } else {
//     runApp(const MyApp());
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // Cấu hình cho web từ project setting firebase console
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBOgmrG1kp2Yd3E2OuUIgD7DhTlQ_b21kw",
          authDomain: "app-zalo-6c0f6.firebaseapp.com",
          projectId: "app-zalo-6c0f6",
          storageBucket: "app-zalo-6c0f6.appspot.com",
          messagingSenderId: "764109092494",
          appId: "1:764109092494:web:447a19473fc072be2f7bdf",
        ),
      );
    } else {
      // Cấu hình cho mobile (Android/iOS)
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Chat App')),
        body: const Center(child: Text('Hello Flutter Web!')),
      ),
    );
  }
}

class MyLoggedApp extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyLoggedApp(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

// chức năng đăng bài
class History extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const History({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
