import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/app/firebase_bootstrap.dart';
import 'package:chat_app/models/firebaseHelper.dart';
import 'package:chat_app/models/userModel.dart';
import 'package:chat_app/pages/Home-Page.dart';
import 'package:chat_app/pages/Main-Page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  await Hive.initFlutter();
  await Hive.openBox("mybox");

  // Khởi tạo Firebase
  await initializeFirebase();

  // Kiểm tra user đã đăng nhập chưa
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Đã đăng nhập — lấy thông tin user và vào MainPage
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyLoggedApp(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    } else {
      // Có user nhưng không lấy được model → về HomePage
      runApp(const MyApp());
    }
  } else {
    // Chưa đăng nhập → vào trang chủ
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
