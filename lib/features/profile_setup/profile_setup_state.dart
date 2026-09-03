import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/core/services/image_service.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupState {
  final AuthStatus status;
  final String fullName;
  final PickedImage? image;
  final AppError? error;
  final User? firebaseUser;
  final UserModel? userModel;

  const ProfileSetupState({
    this.status = AuthStatus.idle,
    this.fullName = '',
    this.image,
    this.error,
    this.firebaseUser,
    this.userModel
  });

  ProfileSetupState copyWith({
    AuthStatus? status,
    String? fullName,
    PickedImage? image,
    AppError? error,
    User? firebaseUser,
    UserModel? userModel
  }) {
    return ProfileSetupState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      image: image ?? this.image,
      error: error,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel
    );
  }
}