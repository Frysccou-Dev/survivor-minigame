import 'package:flutter/material.dart';

enum InlineMessageVariant { info, success, error }

class InlineMessage extends StatelessWidget {
  const InlineMessage({
    super.key,
    required this.message,
    this.variant = InlineMessageVariant.info,
  });

  final String message;
  final InlineMessageVariant variant;

  @override
  Widget build(BuildContext context) {
    final _InlineMessageStyle style =
        _styles[variant] ?? _styles[InlineMessageVariant.info]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: style.textColor, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessageStyle {
  const _InlineMessageStyle({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.textColor,
  });

  final Color background;
  final Color border;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
}

const Map<InlineMessageVariant, _InlineMessageStyle> _styles = {
  InlineMessageVariant.info: _InlineMessageStyle(
    background: Color(0xFF1C1C1C),
    border: Color(0xFF272727),
    icon: Icons.info_outline,
    iconColor: Color(0xFFED9320),
    textColor: Colors.white70,
  ),
  InlineMessageVariant.success: _InlineMessageStyle(
    background: Color(0xFF132119),
    border: Color(0xFF1F6F3D),
    icon: Icons.check_circle_outline,
    iconColor: Color(0xFF3DDB85),
    textColor: Color(0xFFB7FFD1),
  ),
  InlineMessageVariant.error: _InlineMessageStyle(
    background: Color(0xFF24171A),
    border: Color(0xFF812C37),
    icon: Icons.error_outline,
    iconColor: Color(0xFFFF6673),
    textColor: Color(0xFFFFC6CC),
  ),
};
