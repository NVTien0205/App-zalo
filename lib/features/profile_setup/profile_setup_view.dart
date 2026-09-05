import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/components/name_text_field.dart';
import 'package:chat_app/core/widgets/app_snack_bar.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/profile_setup/profile_setup_view_model.dart';
import 'package:chat_app/pages/main_page.dart';

/// Dùng chung cho 2 case: hoàn tất hồ sơ sau Register mới, và hoàn tất hồ sơ
/// cho tài khoản cũ thiếu dữ liệu (Login legacy case).
class ProfileSetupView extends ConsumerStatefulWidget {
  final String uid;

  const ProfileSetupView({super.key, required this.uid});

  @override
  ConsumerState<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends ConsumerState<ProfileSetupView> {
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  void _showPhotoOptions() {
    final viewModel = ref.read(profileSetupViewModelProvider.notifier);
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
                  viewModel.pickImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text('Chọn ảnh từ thư viện'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(dialogContext);
                  viewModel.pickImage(ImageSource.camera);
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
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập họ và tên!');
      return;
    }

    final viewModel = ref.read(profileSetupViewModelProvider.notifier);
    viewModel.setFullName(fullName);
    viewModel.completeProfile(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileSetupViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.failure && next.error != null) {
        showAppSnackBar(context, next.error!.message);
      }
      if (next.status == AuthStatus.success &&
          previous?.status != AuthStatus.success &&
          next.firebaseUser != null && 
          next.userModel != null
          ) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
            builder: (_) => MainPage(
                firebaseUser: next.firebaseUser!,
                userModel: next.userModel!,
              ),
            ),
            (route) => false,
          );
        });
      }
    });

    final state = ref.watch(profileSetupViewModelProvider);
    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text('Hoàn tất đăng ký', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: _showPhotoOptions,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: state.image != null
                      ? MemoryImage(state.image!.bytes)
                      : null,
                  child: state.image == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              MyNameTextField(controller: _fullNameController, name: 'Họ và tên'),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: isLoading ? null : _checkValues,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'XÁC NHẬN',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}