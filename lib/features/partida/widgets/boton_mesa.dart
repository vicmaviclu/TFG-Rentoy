import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(esPantallaPequena ? 8 : 12),
            decoration: BoxDecoration(
              color: Colores.primario.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colores.blanco54, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: esPantallaPequena ? 20 : (esPantallaIntermedia ? 22 : 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: EstilosTexto.cuerpoPequeno.copyWith(
              color: Colores.blanco,
              fontSize: esPantallaPequena
                  ? 10
                  : (esPantallaIntermedia ? 11 : 12),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
