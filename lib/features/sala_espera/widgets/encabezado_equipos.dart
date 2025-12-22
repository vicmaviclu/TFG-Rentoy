import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

class EncabezadoEquipos extends StatelessWidget {
  const EncabezadoEquipos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                TextoPartida.equipo1,
                style: EstilosTexto.subtitulo.copyWith(
                  color: Colores.secundario,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text(
                TextoPartida.equipo2,
                style: EstilosTexto.subtitulo.copyWith(
                  color: Colores.secundario,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
