import 'package:flutter/material.dart';

Future<void> showEditPostDialog({
  required BuildContext context,
  required String initialContent,
  required ValueChanged<String> onChanged,
  required Future<void> Function(String value) onSave,
}) async {
  final controller = TextEditingController(text: initialContent);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Chỉnh sửa bài viết'),
        content: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung bài viết',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await onSave(controller.text.trim());
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );

  controller.dispose();
}

Future<void> showCommentsDialog({
  required BuildContext context,
  required List<Widget> commentTiles,
  required ValueChanged<String> onSubmitted,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Bình luận'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...commentTiles,
            TextField(
              onSubmitted: (text) {
                onSubmitted(text);
                Navigator.of(dialogContext).pop();
              },
              decoration: const InputDecoration(
                hintText: 'Thêm bình luận...',
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<bool> showDeletePostDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Xóa'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<void> showReportDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Báo cáo'),
        content: const Text('Bài viết báo cáo thành công'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      );
    },
  );
}

Future<void> showSearchDialog({
  required BuildContext context,
  required ValueChanged<String> onChanged,
  required VoidCallback onClose,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Tìm kiếm'),
        content: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa',
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onClose();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      );
    },
  );
}
