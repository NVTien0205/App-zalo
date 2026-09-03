import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginState {
  final AuthStatus status;
  final String email;
  final String password;
  final AppError? error;
  final User? firebaseUser;
  final UserModel? userModel;

  const LoginState({
    this.status = AuthStatus.idle,
    this.email = '',
    this.password = '',
    this.error,
    this.firebaseUser,
    this.userModel
  });

  LoginState copyWith ({
    AuthStatus? status,
    String? email,
    String? password,
    AppError? error,
    User? firebaseUser,
    UserModel? userModel
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password:  password ?? this.password,
      error: error,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel
    );
  }
}