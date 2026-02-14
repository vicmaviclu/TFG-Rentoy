import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';

class IndicadorBaza extends StatelessWidget {
  const IndicadorBaza({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colores.blanco, // Siempre blanco
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
