import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';

/// Pantalla de resultado final tras terminar la partida.
class PantallaFinPartida extends StatelessWidget {
  final bool victoria;
  final int puntosEquipo1;
  final int puntosEquipo2;
  final VoidCallback? onVolver;

  const PantallaFinPartida({
    super.key,
    required this.victoria,
    this.puntosEquipo1 = 0,
    this.puntosEquipo2 = 0,
    this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICONO DE RESULTADO ---
              Icon(
                victoria
                    ? Icons.emoji_events
                    : Icons.sentiment_very_dissatisfied,
                size: 80,
                color: victoria ? Colors.amber : Colores.error,
              ),
              // --- TÍTULO DE VICTORIA O DERROTA ---
              const SizedBox(height: 24),
              Text(
                victoria ? TextoPartida.victoria : TextoPartida.derrota,
                style: EstilosTexto.tituloGrande.copyWith(
                  color: victoria ? Colors.amber : Colores.error,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              // --- TARJETA CON PUNTUACIÓN FINAL ---
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colores.primarioOscuro,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colores.blanco12),
                ),
                child: Column(
                  children: [
                    // Puntos del Equipo 1
                    Text(
                      "${TextoPartida.equipo1}: $puntosEquipo1",
                      style: EstilosTexto.subtitulo.copyWith(
                        color: Colores.blanco,
                      ),
                    ),
                    // Puntos del Equipo 2
                    const SizedBox(height: 12),
                    Text(
                      "${TextoPartida.equipo2}: $puntosEquipo2",
                      style: EstilosTexto.subtitulo.copyWith(
                        color: Colores.blanco,
                      ),
                    ),
                  ],
                ),
              ),
              // --- BOTÓN VOLVER AL MENÚ ---
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.acento,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (onVolver != null) {
                      onVolver!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    TextoPartida.volverAlMenu,
                    style: EstilosTexto.boton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
