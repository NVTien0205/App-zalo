import 'package:flutter/material.dart';
import '../../models/article_model.dart';

class CommentsDialogWidget extends StatelessWidget {
  final ArticleModel article;
  final Function(String text) onAddComment;

  const CommentsDialogWidget({
    super.key,
    required this.article,
    required this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return AlertDialog(
      title: const Text('Bình luận'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (article.comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Chưa có bình luận nào.', style: TextStyle(color: Colors.grey)),
            ),
          for (final comment in article.comments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(comment.text),
            ),
          TextField(
            controller: commentController,
            onSubmitted: (text) {
              if (text.trim().isNotEmpty) {
                onAddComment(text.trim());
                Navigator.of(context).pop();
              }
            },
            decoration: const InputDecoration(
              hintText: 'Thêm bình luận...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
