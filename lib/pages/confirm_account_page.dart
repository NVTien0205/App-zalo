// ignore_for_file: file_names, avoid_print

import "dart:typed_data";
import "package:flutter/foundation.dart" show kIsWeb;

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:chat_app/components/NameTextField.dart";
import "package:chat_app/models/userModel.dart";
import "package:chat_app/pages/Main-Page.dart";

const String defaultProfilePictureUrl =
    "https://firebasestorage.googleapis.com/v0/b/YOUR_PROJECT/o/defaults%2Fdefault_avatar.png?alt=media";
// ignore: must_be_immutable
class ConfirmAccount extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ConfirmAccount(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);
  @override
  State<ConfirmAccount> createState() => _ConfirmAccountState();
}

class _ConfirmAccountState extends State<ConfirmAccount> {
  late TextEditingController fullNameController;
  XFile? imageFile;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageFile = pickedFile;
        imageBytes = bytes;
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Chọn ảnh đại diện"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Chọn ảnh từ thư viện"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Chụp một tấm hình"),
                )
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname == "") {
      print("Làm ơn hãy điền đầy đủ thông tin!");
    } else {
      print("Đang cập nhật");
      uploadData();
    }
  }

  void uploadData() async {
    String imageUrl;
    if (imageFile != null) {
      UploadTask uploadTask;
      if (kIsWeb && imageBytes != null) {
        uploadTask = FirebaseStorage.instance
            .ref("profilepictures")
            .child(widget.userModel.uid.toString())
            .putData(imageBytes!);
      } else {
        final bytes = await imageFile!.readAsBytes();
        uploadTask = FirebaseStorage.instance
            .ref("profilepictures")
            .child(widget.userModel.uid.toString())
            .putData(bytes);
      }

      TaskSnapshot snapshot = await uploadTask;

      imageUrl = await snapshot.ref.getDownloadURL();
    } else {
      imageUrl = defaultProfilePictureUrl;
    }
    String fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepicture = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("đang cập nhật");
      print("Đã cập nhật thành công!");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPage(
          firebaseUser: widget.firebaseUser,
          userModel: widget.userModel,
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent.shade700,
          title: const Text(
            "Hoàn tất đăng ký",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        (imageFile != null) ? MemoryImage(imageBytes!) : null,
                    radius: 60,
                    child: (imageFile == null)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                          )
                        : null,
                  ),
                ),
                MyNameTextField(
                  controller: fullNameController,
                  name: "Họ và tên",
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: const Text("XÁC NHẬN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  onPressed: () {
                    checkValues();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
