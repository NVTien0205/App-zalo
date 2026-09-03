import 'dart:typed_data';
import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class RegisterState {
  final AuthStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final AppError? error;
  final User? firebaseUser;
  final UserModel? userModel;
  final XFile? imageFile;
  final Uint8List? imageBytes;

  const RegisterState({
    this.status = AuthStatus.idle,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName ='',
    this.error,
    this.firebaseUser,
    this.userModel,
    this.imageFile,
    this.imageBytes,
  });

  RegisterState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    AppError? error,
    User? firebaseUser,
    UserModel? userModel,
    XFile? imageFile,
    Uint8List? imageBytes,
  }) {
    return RegisterState(
      status : status ?? this.status,
      email : email ?? this.email,
      password : password ?? this.password,
      confirmPassword : confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      error: error,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
      imageFile: imageFile ?? this.imageFile,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

} 