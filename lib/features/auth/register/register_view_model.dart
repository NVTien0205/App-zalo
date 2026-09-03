import 'package:chat_app/app/app.dart';
import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/register/register_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

const String defaultProfilePictureUrl =
    'https://firebasestorage.googleapis.com/v0/b/YOUR_PROJECT/o/defaults%2Fdefault_avatar.png?alt=media';

class RegisterViewModel extends Notifier<RegisterState>{
  @override
  RegisterState build() => const RegisterState();

  AuthService get _authServices => ref.read(authServiceProvider);

  void setEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, error: null);
  }

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName, error: null);
  }



  Future<void> selectImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    state = state.copyWith(imageFile: pickedFile, imageBytes: bytes);
  }

  Future<String> _uploadAvatar(String uid) async {
    if (state.imageFile == null) return defaultProfilePictureUrl;

    UploadTask uploadTask;
    if (kIsWeb && state.imageBytes != null) {
      uploadTask = FirebaseStorage.instance
          .ref('profilepictures')
          .child(uid)
          .putData(state.imageBytes!);
    } else {
      final bytes = await state.imageFile!.readAsBytes();
      uploadTask = FirebaseStorage.instance
          .ref('profilepictures')
          .child(uid)
          .putData(bytes);
    }

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> register() async {
    if (state.status == AuthStatus.loading) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final signUpResult = await _authServices.signUp(
      email: state.email,
      password: state.password,
      fullName: state.fullName,
    );

    final signUpError = signUpResult.fold(
      onSuccess: (_) => null,
      onFailure: (err) => err,
    );

    if (signUpError != null) {
      state = state.copyWith(status: AuthStatus.failure, error: signUpError);
      return;
    }

    final credential = signUpResult.fold(
      onSuccess: (cred) => cred,
      onFailure: (_) => null,
    );
    final firebaseUser = credential?.user;

    if (firebaseUser == null) {
      state = state.copyWith(
        status: AuthStatus.failure,
        error: const AppError(
          code: 'no-firebase-user',
          message: 'Không thể khởi tạo tài khoản sau khi đăng ký.',
        ),
      );
      return;
    }

    final profilePictureUrl = await _uploadAvatar(firebaseUser.uid);

      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: state.email,
        fullname: state.fullName,
        profilepicture: profilePictureUrl,
        friendList: [],
      );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());
    } on FirebaseException catch (ex) {
      state = state.copyWith(
        status: AuthStatus.failure,
        error: AppError(
          code: ex.code,
          message: ex.message ??
              'Đăng ký tài khoản xong nhưng chưa tạo được hồ sơ người dùng.',
        ),
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.success,
      firebaseUser: firebaseUser,
      userModel: newUser,
      error: null,
    );
  }

}
  final registerViewModelProvider = NotifierProvider.autoDispose
  <RegisterViewModel, RegisterState> (
    RegisterViewModel.new);
