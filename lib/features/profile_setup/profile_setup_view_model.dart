import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/profile_setup/profile_setup_state.dart';
import 'package:chat_app/features/user/domain/user_repository.dart';
import 'package:chat_app/core/services/image_service.dart';

/// Dùng chung cho 2 case (lead xác nhận): hoàn tất hồ sơ sau khi Register mới,
/// và hoàn tất hồ sơ cho tài khoản cũ thiếu dữ liệu (Login legacy case).
class ProfileSetupViewModel extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  AuthService get _authService => ref.read(authServiceProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);
  ImageService get _imageService => ref.read(imageServiceProvider);

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName, error: null);
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _imageService.pickImage(source);
    if (image == null) return;
    state = state.copyWith(image: image);
  }

  Future<void> completeProfile({required String uid}) async {
    if (state.status == AuthStatus.loading) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final authResult = await _authService.updateDisplayName(
      newName: state.fullName,
    );

    final authError = authResult.fold(
      onSuccess: (_) => null,
      onFailure: (err) => err,
    );

    if (authError != null) {
      state = state.copyWith(status: AuthStatus.failure, error: authError);
      return;
    }

    final avatarUrl = await _imageService.uploadAvatar(
      uid: uid,
      image: state.image,
    );

    final nameResult = await _userRepository.updateFullName(
      uid: uid,
      newFullName: state.fullName,
    );

    final nameError = nameResult.fold(
      onSuccess: (_) => null,
      onFailure: (err) => err,
    );

    if (nameError != null) {
      state = state.copyWith(status: AuthStatus.failure, error: nameError);
      return;
    }

    final avatarResult = await _userRepository.updateProfilePicture(
      uid: uid,
      profilePictureUrl: avatarUrl,
    );

    avatarResult.fold(
      onSuccess: (_) {
        // Fetch lại UserModel mới nhất từ Firestore + User từ Auth để View
        // có đủ dữ liệu điều hướng vào MainPage (cần cả 2 tham số bắt buộc).
        final firebaseUser = FirebaseAuth.instance.currentUser;

        state = state.copyWith(status: AuthStatus.success, error: null, firebaseUser: firebaseUser);
      },
      onFailure: (err) {
        state = state.copyWith(status: AuthStatus.failure, error: err);
      },
    );
  }
}

final profileSetupViewModelProvider =
    NotifierProvider.autoDispose<ProfileSetupViewModel, ProfileSetupState>(
  ProfileSetupViewModel.new,
);