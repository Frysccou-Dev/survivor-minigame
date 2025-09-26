import 'package:flutter/material.dart';
import 'nav_tab.dart';

class SecondaryNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const SecondaryNav({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color inactiveColor = Color(0xFF1A1A1A);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: NavTab(
              label: 'Por Jugar',
              isActive: activeIndex == 0,
              background: inactiveColor,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NavTab(
              label: 'Resultados',
              isActive: activeIndex == 1,
              background: inactiveColor,
              onTap: () => onChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NavTab(
              label: 'Tabla',
              isActive: activeIndex == 2,
              background: inactiveColor,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}
