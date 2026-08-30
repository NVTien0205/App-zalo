import 'package:flutter/material.dart';

class ArticleActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const ArticleActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, size: 23, color: iconColor),
            const SizedBox(width: 3),
            Text(label),
          ],
        ),
      ),
    );
  }
}
