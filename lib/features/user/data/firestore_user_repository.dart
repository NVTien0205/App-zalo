import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:chat_app/features/user/domain/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  FirestoreUserRepository({ FirebaseFirestore? firstore})
    : _firestore = firstore ?? FirebaseFirestore.instance;


  @override
  Future<Result<void>> updateFullName({
    required String uid,
    required String newFullName
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({'fullname' : newFullName});
      return const Success(null);
    } on FirebaseException catch (ex) {
      return Failure(AppError(
        code: ex.code,
        message: ex.message ?? 'Không thể cập nhật tên, vui lòng thử lại.'
      ));
    }
  }
}