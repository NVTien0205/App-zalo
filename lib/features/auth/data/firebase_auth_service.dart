import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:chat_app/core/errors/auth_error_mapper.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';

/// Implementation thật của AuthService, gọi trực tiếp Firebase Auth SDK.
/// Đổi tên từ auth_service.dart cũ (T-06 gốc) sang đây khi nâng cấp thành
/// Repository Pattern — nội dung logic giữ nguyên, chỉ đổi vị trí + implements.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  @override
  Future<Result<UserCredential>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Success(null);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }
}
