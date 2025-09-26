import 'package:flutter/material.dart';

class PickOptionButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const PickOptionButton({
    super.key,
    required this.label,
    required this.flag,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? const Color(0xFFED9320)
        : const Color(0xFF1C1C1C);
    final Color borderColor = selected
        ? const Color(0xFFED9320)
        : const Color(0xFF2A2A2A);
    final Color textColor = selected ? Colors.black : Colors.white70;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
