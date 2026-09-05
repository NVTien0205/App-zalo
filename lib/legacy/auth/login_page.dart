// ignore_for_file: file_names

import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/legacy/auth/confirm_account_page.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String _mapAuthError(FirebaseAuthException ex) {
    switch (ex.code) {
      case 'invalid-email':
        return 'Email không hợp lệ!';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email hoặc mật khẩu không đúng.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Thiết bị đang bị chặn tạm thời do thử quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng, vui lòng thử lại!';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }

  void checkValues(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      showAppSnackBar(context, emailError);
      return;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      showAppSnackBar(context, passwordError);
      return;
    }

    login(email, password, context);
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    UserCredential credential;

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      if (!context.mounted) return;
      showAppSnackBar(context, _mapAuthError(ex));
      return;
    } catch (e) {
      debugPrint('Login debug -> unexpected auth error: $e');
      if (!context.mounted) return;
      showAppSnackBar(context, 'Đăng nhập thất bại. Vui lòng thử lại.');
      return;
    }

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      if (!context.mounted) return;
      showAppSnackBar(context, 'Không thể xác định tài khoản đăng nhập.');
      return;
    }

    DocumentSnapshot<Map<String, dynamic>> userDoc;
    try {
      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
    } on FirebaseException catch (ex) {
      debugPrint('Login debug -> firestore error: ${ex.message}');
      if (!context.mounted) return;
      showAppSnackBar(context, ex.message ?? 'Không thể tải hồ sơ người dùng.');
      return;
    } catch (e) {
      debugPrint('Login debug -> unexpected firestore error: $e');
      if (!context.mounted) return;
      showAppSnackBar(context, 'Không thể tải hồ sơ người dùng.');
      return;
    }

    final userData = userDoc.data();
    if (userData == null) {
      debugPrint('Login debug -> missing profile for uid: ${firebaseUser.uid}');
      if (!context.mounted) return;

      showAppSnackBar(
        context,
        'Tài khoản đã tồn tại nhưng chưa có hồ sơ người dùng.',
      );

      final incompleteUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        fullname: '',
        friendList: [],
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmAccount(
            firebaseUser: firebaseUser,
            userModel: incompleteUser,
          ),
        ),
      );
      return;
    }

    final userModel = UserModel.fromMap(userData);
    debugPrint('Login debug -> login success for uid: ${firebaseUser.uid}');

    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Đăng nhập thành công. Xin chào ${userModel.fullname ?? userModel.email ?? ''}!',
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainPage(
          firebaseUser: firebaseUser,
          userModel: userModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            child: const Row(
              children: [
                SizedBox(width: 20.0),
                Text('Nhập số điện thoại và mật khẩu để đăng nhập'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 35.0),
                MyEmailTextField(controller: emailController),
                const SizedBox(height: 20.0),
                MyPasswordTextField(
                  controller: passwordController,
                  myText: 'Mật khẩu',
                ),
                const SizedBox(height: 15.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lấy lại mật khẩu',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkValues(context);
        },
        shape: const StadiumBorder(),
        backgroundColor: Colors.blueAccent.shade700,
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
