import 'package:flutter/material.dart';

/// Nút bấm chạy hành động bất đồng bộ (gọi API, v.v.), tự quản lý loading state.
/// KHÔNG wrap MyButton (MyButton chỉ dùng để điều hướng trang qua Navigator.push,
/// không phù hợp cho async action — xem ghi chú audit T-04).
/// Style thị giác tham chiếu theo MyButton để đồng nhất UI.
class AppAsyncButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Future<void> Function() onPressed;

  const AppAsyncButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<AppAsyncButton> createState() => _AppAsyncButtonState();
}

class _AppAsyncButtonState extends State<AppAsyncButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          padding: const EdgeInsets.all(15),
        ),
        onPressed: _isLoading ? null : _handlePressed,
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.textColor,
                ),
              )
            : Text(widget.text, style: TextStyle(color: widget.textColor)),
      ),
    );
  }
}
