import 'package:flutter/material.dart';

class LivesDepletedBanner extends StatelessWidget {
  const LivesDepletedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A1A1A)),
      ),
      child: Row(
        children: const [
          Icon(Icons.block, color: Color(0xFFFF5C5C), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Has perdido todas tus vidas. Mejor suerte la próxima.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
