import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/register/register_view_model.dart';
import 'package:chat_app/features/profile_setup/profile_setup_view.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }



  void _checkValues() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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

    final confirmPasswordError =
        Validators.validateConfirmPassword(password, confirmPassword);
    if (confirmPasswordError != null) {
      showAppSnackBar(context, confirmPasswordError);
      return;
    }
  

    final viewModel = ref.read(registerViewModelProvider.notifier);
    viewModel.setEmail(email);
    viewModel.setPassword(password);
    viewModel.setConfirmPassword(confirmPassword);
    viewModel.register();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(registerViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.failure && next.error != null) {
        showAppSnackBar(context, next.error!.message);
      }
      if (next.status == AuthStatus.success &&
          previous?.status != AuthStatus.success &&
          next.firebaseUser != null) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileSetupView(uid: next.firebaseUser!.uid),
            ),
          );
        });
      }
    });

    final state = ref.watch(registerViewModelProvider);
    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 88, 235),
        title: const Text('Tạo tài khoản', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 25.0),
            MyEmailTextField(controller: _emailController),
            const SizedBox(height: 20.0),
            MyPasswordTextField(controller: _passwordController, myText: 'Mật khẩu'),
            const SizedBox(height: 20.0),
            MyPasswordTextField(
              controller: _confirmPasswordController,
              myText: 'Xác nhận mật khẩu',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _checkValues,
        backgroundColor: Colors.blueAccent.shade700,
        shape: const StadiumBorder(),
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