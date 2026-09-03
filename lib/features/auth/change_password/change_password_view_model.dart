import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/change_password/change_password_state.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordViewModel extends Notifier<ChangePasswordState>{
  @override
  ChangePasswordState build() => const ChangePasswordState();
  AuthService get _authService => ref.read(authServiceProvider);

  void setCurrentPassword(String currentPassword) {
    state = state.copyWith(currentPassword: currentPassword, error: null);
  }

  void setNewPassword(String newPassword) {
    state = state.copyWith(newPassword: newPassword, error: null);
  }

  void changePassword() async {
    if (state.status == AuthStatus.loading) return null;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.changePassword(
      currentPassword: state.currentPassword,
      newPassword: state.newPassword
    );
    result.fold(
      onSuccess: (_) {
        state = state.copyWith(status: AuthStatus.success, error: null);
      },
      onFailure: (err) {
        state = state.copyWith(status: AuthStatus.failure, error: err);
      }
    );
  }
} 

final changePasswordViewModelProvider = NotifierProvider.autoDispose
    <ChangePasswordViewModel, ChangePasswordState>(
  ChangePasswordViewModel.new,
);