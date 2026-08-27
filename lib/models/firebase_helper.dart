// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/user_model.dart';

class FirebaseHelper {
  Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
