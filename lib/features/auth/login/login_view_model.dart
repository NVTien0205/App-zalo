import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/login/login_state.dart';
import 'package:chat_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();
  AuthService get _authService => ref.read(authServiceProvider);

  void setEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  Future<void> login() async {
    if (state.status == AuthStatus.loading) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final authResult = await _authService.signIn(
      email: state.email,
      password: state.password,
    );

    final signInError = authResult.fold(
      onSuccess: (_) => null,
      onFailure: (err) => err,
    );

    if (signInError != null) {
      state = state.copyWith(status: AuthStatus.failure, error: signInError);
      return;
    }

    final credential = authResult.fold(
      onSuccess: (cred) => cred,
      onFailure: (_) => null,
    );
    final firebaseUser = credential?.user;

    if (firebaseUser == null) {
      state = state.copyWith(
        status: AuthStatus.failure,
        error: const AppError(
          code: 'no-firebase-user',
          message: 'Không thể xác định tài khoản đăng nhập.',
        ),
      );
      return;
    }


    final firebaseHelper = ref.read(databaseServiceProvider);
    final userModel = await firebaseHelper.getUserModelById(firebaseUser.uid);

    state = state.copyWith(
      status: AuthStatus.success,
      firebaseUser: firebaseUser,
      userModel: userModel,
      error: null,
    );
  }

}

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new);