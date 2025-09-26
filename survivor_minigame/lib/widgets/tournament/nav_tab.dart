import 'package:flutter/material.dart';

class NavTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color background;
  final VoidCallback onTap;

  const NavTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground = isActive
        ? const Color(0xFFED9320)
        : background;
    final Color textColor = isActive ? Colors.black : Colors.white70;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: resolvedBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
