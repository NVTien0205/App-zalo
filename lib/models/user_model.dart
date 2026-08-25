// ignore_for_file: file_names

class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepicture;
  List<String>? friendList;
  UserModel(
      {this.uid,
      this.fullname,
      this.email,
      this.profilepicture,
      this.friendList});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepicture = map["profilepicture"];

    friendList = List<String>.from(map["friendList"] ?? []);
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepicture": profilepicture,
      "friendList": friendList ?? [],
    };
  }
}
