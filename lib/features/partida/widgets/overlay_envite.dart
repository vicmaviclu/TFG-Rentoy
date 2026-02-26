import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

import '../../../core/constantes/cadenas.dart';

class OverlayEnvite extends StatelessWidget {
  final int puntosActuales;
  final VoidCallback onAceptar;
  final VoidCallback onReenviar;

  const OverlayEnvite({
    super.key,
    required this.puntosActuales,
    required this.onAceptar,
    required this.onReenviar,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colores.acento, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, size: 48, color: Colores.acento),
                const SizedBox(height: 16),
                Text(
                  TextoPartida.tituloEnvite,
                  style: EstilosTexto.tituloMedio.copyWith(
                    color: Colores.blanco,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${TextoPartida.enviteSubeA}${puntosActuales == 1 ? 3 : puntosActuales + 3} ${TextoPartida.puntos}.",
                  textAlign: TextAlign.center,
                  style: EstilosTexto.subtitulo.copyWith(
                    color: Colores.blanco70,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: onReenviar,
                      child: const Text(
                        TextoPartida.btnReenviar,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.primario,
                      ),
                      onPressed: onAceptar,
                      child: const Text(
                        TextoComun.aceptar,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
