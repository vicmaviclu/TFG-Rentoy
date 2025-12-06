import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';

/// Selector simple de avatar: muestra círculo con número y botones para cambiar.
class AvatarSelector extends StatelessWidget {
  const AvatarSelector({super.key, required this.valor, required this.onChanged});

  final int valor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text('$valor', style: const TextStyle(fontSize: 24, color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => onChanged((valor - 1).clamp(1, 9)),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            const SizedBox(width: 8),
            Text(Cadenas.avatar),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onChanged((valor + 1).clamp(1, 9)),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}
