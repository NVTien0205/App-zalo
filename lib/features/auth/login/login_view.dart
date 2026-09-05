import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/login/login_view_model.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/features/profile_setup/profile_setup_view.dart';
import 'package:chat_app/models/user_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkValues() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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

    final viewModel = ref.read(loginViewModelProvider.notifier);
    viewModel.setEmail(email);
    viewModel.setPassword(password);
    viewModel.login();
  }

  Future<void> _navigateAfterLogin(User? firebaseUser, UserModel? userModel) async {
    if (firebaseUser == null || !mounted) return;

    if (userModel == null) {
      showAppSnackBar(context, 'Tài khoản đã tồn tại nhưng chưa có hồ sơ người dùng.');
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupView(uid: firebaseUser.uid),
        ),
      );
      return;
    }

    showAppSnackBar(
      context,
      'Đăng nhập thành công. Xin chào ${userModel.fullname ?? userModel.email ?? ''}!',
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainPage(firebaseUser: firebaseUser, userModel: userModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.failure && next.error != null) {
        showAppSnackBar(context, next.error!.message);
      }
      if (next.status == AuthStatus.success &&
          previous?.status != AuthStatus.success) {
        _navigateAfterLogin(next.firebaseUser, next.userModel);
      }
    });

    final state = ref.watch(loginViewModelProvider);
    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.grey.shade300),
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
                MyEmailTextField(controller: _emailController),
                const SizedBox(height: 20.0),
                MyPasswordTextField(controller: _passwordController, myText: 'Mật khẩu'),
                const SizedBox(height: 15.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lấy lại mật khẩu', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _checkValues,
        shape: const StadiumBorder(),
        backgroundColor: Colors.blueAccent.shade700,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}