import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterState {
  final AuthStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final AppError? error;
  final User? firebaseUser;
  final UserModel? userModel;

  const RegisterState({
    this.status = AuthStatus.idle,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.error,
    this.firebaseUser,
    this.userModel,
  });

  RegisterState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    AppError? error,
    User? firebaseUser,
    UserModel? userModel,
  }) {
    return RegisterState(
      status : status ?? this.status,
      email : email ?? this.email,
      password : password ?? this.password,
      confirmPassword : confirmPassword ?? this.confirmPassword,
      error: error,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
    );
  }

} 