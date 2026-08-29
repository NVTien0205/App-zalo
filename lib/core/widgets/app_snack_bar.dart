import 'dart:async';
import 'package:flutter/material.dart';

/// Helper hiển thị thông báo dạng toast gọn theo nội dung chữ.
void showAppSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  final bottomInset = MediaQuery.of(context).viewInsets.bottom;
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 24,
        right: 24,
        bottom: bottomInset > 0 ? bottomInset + 24 : 96,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F97A5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
  unawaited(
    Future<void>.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    }),
  );
}
