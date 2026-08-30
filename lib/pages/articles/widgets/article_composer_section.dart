import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/articles/widgets/article_action_button.dart';
import 'package:flutter/material.dart';

class ArticleComposerSection extends StatelessWidget {
  final UserModel userModel;
  final TextEditingController postController;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;
  final VoidCallback onCreateAlbum;

  const ArticleComposerSection({
    super.key,
    required this.userModel,
    required this.postController,
    required this.onPickImage,
    required this.onSubmit,
    required this.onCreateAlbum,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(userModel.profilepicture ?? ''),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.only(left: 12, top: 8),
              height: 70,
              width: 270,
              child: TextField(
                controller: postController,
                maxLines: null,
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
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: ArticleActionButton(
                icon: Icons.photo_rounded,
                iconColor: Colors.green,
                label: 'Đăng ảnh',
                onTap: onPickImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ArticleActionButton(
                icon: Icons.post_add_rounded,
                iconColor: Colors.red,
                label: 'Đăng bài',
                onTap: onSubmit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ArticleActionButton(
                icon: Icons.photo_camera_back_outlined,
                iconColor: Colors.deepPurpleAccent.shade700,
                label: 'Tạo album',
                onTap: onCreateAlbum,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}
