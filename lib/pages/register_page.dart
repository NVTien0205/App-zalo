// ignore_for_file: file_names

import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/confirm_account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String _mapAuthError(FirebaseAuthException ex) {
    switch (ex.code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng để đăng ký!';
      case 'weak-password':
        return 'Mật khẩu quá yếu, vui lòng chọn mật khẩu khác!';
      case 'invalid-email':
        return 'Email không hợp lệ!';
      case 'too-many-requests':
        return 'Thiết bị đang bị chặn tạm thời do thử quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng, vui lòng thử lại!';
      default:
        return 'Đăng ký thất bại, vui lòng thử lại sau!';
    }
  }

  void checkValues(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

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

    final confirmPasswordError = Validators.validateConfirmPassword(
      password,
      confirmPassword,
    );
    if (confirmPasswordError != null) {
      showAppSnackBar(context, confirmPasswordError);
      return;
    }

    signUp(email, password, context);
  }

  Future<void> signUp(
    String email,
    String password,
    BuildContext context,
  ) async {
    UserCredential credential;

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      if (!context.mounted) return;
      showAppSnackBar(context, _mapAuthError(ex));
      return;
    } catch (e) {
      debugPrint('Register debug -> unexpected auth error: $e');
      if (!context.mounted) return;
      showAppSnackBar(context, 'Đăng ký thất bại, vui lòng thử lại sau!');
      return;
    }

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      if (!context.mounted) return;
      showAppSnackBar(context, 'Không thể khởi tạo tài khoản sau khi đăng ký.');
      return;
    }

    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: email,
      fullname: '',
      profilepicture: '',
      friendList: [],
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());
    } on FirebaseException catch (ex) {
      debugPrint('Register debug -> firestore error: ${ex.message}');
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        ex.message ??
            'Đăng ký tài khoản xong nhưng chưa tạo được hồ sơ người dùng.',
      );
      return;
    } catch (e) {
      debugPrint('Register debug -> unexpected firestore error: $e');
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        'Đăng ký tài khoản xong nhưng chưa tạo được hồ sơ người dùng.',
      );
      return;
    }

    if (!context.mounted) return;
    showAppSnackBar(context, 'Đăng ký thành công. Mời bạn hoàn tất hồ sơ.');

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmAccount(
          firebaseUser: firebaseUser,
          userModel: newUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 88, 235),
        title: const Text(
          'Tạo tài khoản',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 25.0),
                MyEmailTextField(controller: emailController),
                const SizedBox(height: 20.0),
                MyPasswordTextField(
                  controller: passwordController,
                  myText: 'Mật khẩu',
                ),
                const SizedBox(height: 20.0),
                MyPasswordTextField(
                  controller: confirmPasswordController,
                  myText: 'Xác nhận mật khẩu',
                ),
                const SizedBox(height: 20.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Những lưu ý khi đặt tên:'),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text('- Đặt tên phù hợp với'),
                        SizedBox(width: 5),
                        Text(
                          'điều khoản của Zalo',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('- Sử dụng tên thật để mọi người dễ nhận ra bạn'),
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
        backgroundColor: Colors.blueAccent.shade700,
        shape: const StadiumBorder(),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
