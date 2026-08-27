// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/confirm_account_page.dart';

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final RegExp _emailRegex = RegExp(r"^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$");

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void checkValues(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = confirmPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      _showSnack(context, "Vui lòng đừng để trống các ô!");
    } else if (!_emailRegex.hasMatch(email)) {
      _showSnack(context, "Email không đúng định dạng!");
    } else if (password.length < 6) {
      _showSnack(context, "Mật khẩu phải có ít nhất 6 ký tự!");
    } else if (password != cPassword) {
      _showSnack(context, "Mật khẩu xác nhận không trùng khớp!");
    } else {
      signUp(email, password, context);
    }
  }

  Future<void> signUp(
      String email, String password, BuildContext context) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      String message;
      switch (ex.code) {
        case "email-already-in-use":
          message = "Email này đã được sử dụng để đăng ký!";
          break;
        case "weak-password":
          message = "Mật khẩu quá yếu, vui lòng chọn mật khẩu khác!";
          break;
        case "invalid-email":
          message = "Email không hợp lệ!";
          break;
        case "network-request-failed":
          message = "Lỗi kết nối mạng, vui lòng thử lại!";
          break;
        default:
          message = "Đăng ký thất bại, vui lòng thử lại sau!";
      }
      if (!context.mounted) return;
      _showSnack(context, message);
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepicture: "",
        friendList: [],
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap());

      print("Đăng ký thành công!");

      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConfirmAccount(
          firebaseUser: credential!.user!,
          userModel: newUser,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 88, 235),
        title: const Text(
          "Tạo tài khoản",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              const SizedBox(height: 25.0),

              //Phone number textfield

              MyEmailTextField(
                controller: emailController,
              ),
              const SizedBox(height: 20.0),

              //Password textfield

              MyPasswordTextField(
                  controller: passwordController, myText: "Mật khẩu"),
              const SizedBox(height: 20.0),

              //Confirm password
              MyPasswordTextField(
                  controller: confirmPasswordController,
                  myText: "Xác nhận mật khẩu"),
              const SizedBox(height: 20.0),
              //Dieu khoan cua app

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Những lưu ý khi đặt tên:",
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("- Đặt tên phù hợp với"),
                      SizedBox(width: 5),
                      Text("điều khoản của Zalo",
                          style: TextStyle(color: Colors.blue))
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                      "- Sử dụng tên thật để mọi người dễ nhận ra bạn"),
                ],
              ),
            ]),
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
