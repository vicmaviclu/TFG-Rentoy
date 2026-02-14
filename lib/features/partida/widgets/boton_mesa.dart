import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';

class BotonMesa extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BotonMesa({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colores.primario.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colores.blanco54, width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
