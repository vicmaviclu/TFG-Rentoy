import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';

class OverlayEnvite extends StatelessWidget {
  final int puntosActuales;
  final VoidCallback onNoQuiero;
  final VoidCallback onQuiero;
  final VoidCallback onReenvitar;

  const OverlayEnvite({
    super.key,
    required this.puntosActuales,
    required this.onNoQuiero,
    required this.onQuiero,
    required this.onReenvitar,
  });

  @override
  Widget build(BuildContext context) {
    final int puntosEnDisputa = puntosActuales == 1 ? 3 : puntosActuales + 3;

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
                  '${TextoPartida.enviteSubeA}$puntosEnDisputa ${TextoPartida.puntos}.',
                  textAlign: TextAlign.center,
                  style: EstilosTexto.subtitulo.copyWith(
                    color: Colores.blanco70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Si rechazas, el rival gana ${puntosActuales == 1 ? 1 : puntosActuales} ${TextoPartida.puntos}.',
                  textAlign: TextAlign.center,
                  style: EstilosTexto.cuerpoPequeno.copyWith(
                    color: Colors.redAccent.shade100,
                  ),
                ),
                const SizedBox(height: 24),
                // Fila superior: NO QUIERO (rojo) y QUIERO (verde)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onNoQuiero,
                        child: const Text(
                          TextoPartida.btnNoQuiero,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onQuiero,
                        child: const Text(
                          TextoPartida.btnQuiero,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Fila inferior: REENVITAR (naranja, full width)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colores.acento,
                      side: BorderSide(color: Colores.acento),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onReenvitar,
                    child: const Text(
                      TextoPartida.btnReenviar,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
