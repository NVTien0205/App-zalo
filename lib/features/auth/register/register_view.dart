import 'package:chat_app/components/name_text_field.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/components/email_text_field.dart';
import 'package:chat_app/components/password_text_field.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/register/register_view_model.dart';
import 'package:image_picker/image_picker.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

   void _showPhotoOptions() {
    final viewModel = ref.read(registerViewModelProvider.notifier);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chọn ảnh đại diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(dialogContext);
                  viewModel.selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text('Chọn ảnh từ thư viện'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(dialogContext);
                  viewModel.selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp một tấm hình'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkValues() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final fullName = _fullNameController.text.trim();

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
    
    if (fullName.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập họ và tên!');
      return;
    }

    final viewModel = ref.read(registerViewModelProvider.notifier);
    viewModel.setEmail(email);
    viewModel.setPassword(password);
    viewModel.setConfirmPassword(confirmPassword);
    viewModel.setFullName(fullName);
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
          next.firebaseUser != null &&
          next.userModel != null) {
        showAppSnackBar(context, 'Đăng ký thành công. Mời bạn hoàn tất hồ sơ.');
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainPage(
                firebaseUser: next.firebaseUser!,
                userModel: next.userModel!,
              ),
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
              body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 25.0),
                CupertinoButton(
                  onPressed: _showPhotoOptions,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: state.imageBytes != null
                        ? MemoryImage(state.imageBytes!)
                        : null,
                    child: state.imageBytes == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20.0),
                MyEmailTextField(controller: _emailController),
                const SizedBox(height: 20.0),
                MyPasswordTextField(controller: _passwordController, myText: 'Mật khẩu'),
                const SizedBox(height: 20.0),
                MyPasswordTextField(
                  controller: _confirmPasswordController,
                  myText: 'Xác nhận mật khẩu',
                ),
                const SizedBox(height: 20.0),
                MyNameTextField(controller: _fullNameController, name: 'Họ và tên'),
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
                        Text('điều khoản của Zalo', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('- Sử dụng tên thật để mọi người dễ nhận ra bạn'),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
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