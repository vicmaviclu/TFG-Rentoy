import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

class MesaJuego extends StatelessWidget {
  const MesaJuego({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colores.primario.withOpacity(0.5), // Or a felt color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.blanco24, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Mesa de Juego',
            style: EstilosTexto.tituloMedio.copyWith(color: Colores.blanco70),
          ),
        ),
      ),
    );
  }
}
