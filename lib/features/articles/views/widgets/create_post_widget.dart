import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';

import '../../models/articles_state.dart';

class CreatePostWidget extends StatelessWidget {
  final UserModel userModel;
  final TextEditingController postController;
  final ArticlesState state;
  final ValueChanged<String> onPostTextChanged;
  final VoidCallback onPickImage;
  final VoidCallback onSubmitPost;

  const CreatePostWidget({
    super.key,
    required this.userModel,
    required this.postController,
    required this.state,
    required this.onPostTextChanged,
    required this.onPickImage,
    required this.onSubmitPost,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 22,
              backgroundImage: userModel.profilepicture != null &&
                      userModel.profilepicture!.isNotEmpty
                  ? NetworkImage(userModel.profilepicture!)
                  : null,
              child: userModel.profilepicture == null ||
                      userModel.profilepicture!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.only(left: 12, top: 8),
              height: 70,
              width: screenWidth * 0.7,
              child: TextField(
                controller: postController,
                maxLines: null,
                onChanged: onPostTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Nhập nội dung bài đăng...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: onPickImage,
                borderRadius: BorderRadius.circular(21),
                child: Ink(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    color: const Color.fromARGB(255, 246, 240, 240),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_rounded, size: 23, color: Colors.green),
                      SizedBox(width: 3),
                      Text('Đăng ảnh'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: state.isSubmitting ? null : onSubmitPost,
                borderRadius: BorderRadius.circular(21),
                child: Ink(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    color: const Color.fromARGB(255, 246, 240, 240),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.post_add_rounded,
                              size: 23,
                              color: Colors.red,
                            ),
                      const SizedBox(width: 3),
                      Text(state.isSubmitting ? 'Đang gửi...' : 'Đăng bài'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(21),
                child: Ink(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    color: const Color.fromARGB(255, 246, 240, 240),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_back_outlined,
                        size: 23,
                        color: Colors.deepPurpleAccent[700],
                      ),
                      const SizedBox(width: 3),
                      const Text('Tạo album'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          color: const Color.fromARGB(255, 236, 236, 236),
        ),
        if (state.selectedImageBytes != null)
          SizedBox(
            width: screenWidth,
            height: 250,
            child: Image.memory(state.selectedImageBytes!, fit: BoxFit.cover),
          ),
      ],
    );
  }
}
