import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';

/// Widget que muestra el marcador de puntos de ambos equipos.
class TableroPuntos extends StatelessWidget {
  /// Puntos del equipo 1
  final int puntosEquipo1;

  /// Puntos del equipo 2
  final int puntosEquipo2;

  /// Objetivo de puntos para ganar
  final int objetivo;

  const TableroPuntos({
    super.key,
    required this.puntosEquipo1,
    required this.puntosEquipo2,
    this.objetivo = 21,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;

    // --- CONTENEDOR PRINCIPAL DEL MARCADOR ---
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: esPantallaPequena ? 12 : (esPantallaIntermedia ? 16 : 24),
        vertical: esPantallaPequena ? 8 : (esPantallaIntermedia ? 10 : 12),
      ),
      decoration: BoxDecoration(
        color: Colores.primarioOscuro.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.blanco24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Puntos del Equipo 1
          _PuntosEquipo(
            nombre: TextoPartida.equipo1,
            puntos: puntosEquipo1,
            color: Colores.acento,
          ),
          SizedBox(width: esPantallaPequena ? 8 : 16),
          // Objetivo de puntos para ganar
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TextoPartida.objetivo,
                style: EstilosTexto.cuerpoPequeno.copyWith(
                  color: Colores.blanco54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$objetivo",
                style: EstilosTexto.tituloPequeno.copyWith(
                  color: Colores.blanco,
                  fontSize: esPantallaPequena
                      ? 12
                      : (esPantallaIntermedia ? 13 : 14), // Adjust size
                ),
              ),
            ],
          ),
          SizedBox(width: esPantallaPequena ? 8 : 16),
          // Puntos del Equipo 2
          _PuntosEquipo(
            nombre: TextoPartida.equipo2,
            puntos: puntosEquipo2,
            color: Colores.secundario,
          ),
        ],
      ),
    );
  }
}

/// Widget privado para mostrar los puntos de un equipo.
class _PuntosEquipo extends StatelessWidget {
  final String nombre;
  final int puntos;
  final Color color;

  const _PuntosEquipo({
    required this.nombre,
    required this.puntos,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // --- COLUMNA: NOMBRE + PUNTOS ---
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          nombre,
          style: EstilosTexto.cuerpoPequeno.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$puntos ${TextoPartida.puntos}",
          style: EstilosTexto.cuerpo.copyWith(color: Colores.blanco),
        ),
      ],
    );
  }
}
