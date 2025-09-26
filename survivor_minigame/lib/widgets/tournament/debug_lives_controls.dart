import 'package:flutter/material.dart';

class DebugLivesControls extends StatelessWidget {
  final VoidCallback onLoseLife;
  final VoidCallback onResetLives;

  const DebugLivesControls({
    super.key,
    required this.onLoseLife,
    required this.onResetLives,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF181818),
      side: const BorderSide(color: Color(0xFF2A2A2A)),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: style,
            onPressed: onLoseLife,
            child: const Text(
              'Simular perder 1 vida',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            style: style,
            onPressed: onResetLives,
            child: const Text(
              'Resetear vidas a 3',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
