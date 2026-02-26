import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../models/usuario_model.dart';
import '../controllers/controlador_partida.dart';
import 'contenedor_equipo.dart';
import 'tablero_puntos.dart';
import 'mesa_juego.dart';
import '../../../core/constantes/textos.dart';

/// Widget englobador que estructura visualmente los 3 bloques principales
/// de la pantalla: Rival (Arriba), Mesa (Centro), Mi Equipo (Abajo).
class VistaPartida extends StatelessWidget {
  final List<UsuarioModel> jugadores;
  final String miUid;
  final bool esMiTurno;
  final int? cartaSeleccionadaIndex;
  final bool ocultarCartas;
  final Map datosPartida;
  final ControladorPartida controlador;
  final String idSesion;
  final Function(int) onSeleccionarCarta;
  final VoidCallback onLanzarCarta;
  final VoidCallback onCambiarCartas;
  final VoidCallback? onCantar;

  const VistaPartida({
    super.key,
    required this.jugadores,
    required this.miUid,
    required this.esMiTurno,
    required this.cartaSeleccionadaIndex,
    required this.ocultarCartas,
    required this.datosPartida,
    required this.controlador,
    required this.idSesion,
    required this.onSeleccionarCarta,
    required this.onLanzarCarta,
    required this.onCambiarCartas,
    required this.onCantar,
  });

  @override
  Widget build(BuildContext context) {
    // Organizar equipos
    final equipos = controlador.organizarEquipos(jugadores, miUid);
    final equipoAbajo = equipos['abajo']!;
    final equipoArriba = equipos['arriba']!;
    final soyEquipo1 = controlador.soyEquipo1(jugadores, miUid);

    String tituloEquipoArriba = soyEquipo1
        ? TextoPartida.equipo2
        : TextoPartida.equipo1;
    String tituloEquipoAbajo = soyEquipo1
        ? TextoPartida.equipo1
        : TextoPartida.equipo2;

    // Puntos
    int p1 = 0;
    int p2 = 0;
    if (datosPartida['puntos'] is Map) {
      final pts = datosPartida['puntos'];
      p1 = (pts['equipo1'] is int) ? pts['equipo1'] : 0;
      p2 = (pts['equipo2'] is int) ? pts['equipo2'] : 0;
    }

    final mostrarBoton = esMiTurno && cartaSeleccionadaIndex != null;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;

    // Extract Turno actual and Bazas ganadas (Refactored logic to ControladorPartida)
    int turnoActual = controlador.obtenerTurnoActual(datosPartida);
    Map<String, int> bazasGanadas = controlador.obtenerBazasGanadas(
      datosPartida,
    );
    int bazasEq1 = bazasGanadas['equipo1'] ?? 0;
    int bazasEq2 = bazasGanadas['equipo2'] ?? 0;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double alturaCarta =
        (screenHeight *
                (esPantallaPequena
                    ? 0.15
                    : (esPantallaIntermedia ? 0.16 : 0.18)))
            .clamp(
              esPantallaPequena ? 80.0 : (esPantallaIntermedia ? 90.0 : 100.0),
              esPantallaPequena
                  ? 120.0
                  : (esPantallaIntermedia ? 135.0 : 150.0),
            );

    return Column(
      children: [
        // --- EQUIPO RIVAL (ARRIBA) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tituloEquipoArriba,
                style: EstilosTexto.subtitulo.copyWith(color: Colores.blanco70),
              ),
              const SizedBox(height: 4),
              ContenedorEquipo(
                jugadores: equipoArriba,
                miUid: miUid,
                cartaSeleccionadaIndex: null,
                onSeleccionar: null,
                turnoActual: turnoActual,
                alturaCarta: alturaCarta,
              ),
            ],
          ),
        ),

        // --- MARCADOR DE PUNTOS ---
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
          child: TableroPuntos(puntosEquipo1: p1, puntosEquipo2: p2),
        ),

        // --- MESA DE JUEGO (CENTRO) ---
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
              child: SizedBox(
                width: double.infinity,
                child: MesaJuego(
                  controlador: controlador,
                  idSesion: idSesion,
                  mostrarBotonLanzar: mostrarBoton,
                  onLanzar: onLanzarCarta,
                  onCambiar: onCambiarCartas,
                  onCantar: onCantar,
                  alturaCarta: alturaCarta,
                  bazasEquipo1: bazasEq1,
                  bazasEquipo2: bazasEq2,
                  soyEquipo1: soyEquipo1,
                ),
              ),
            ),
          ),
        ),

        // --- MI EQUIPO (ABAJO) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ContenedorEquipo(
                jugadores: equipoAbajo,
                miUid: miUid,
                cartaSeleccionadaIndex: cartaSeleccionadaIndex,
                onSeleccionar: onSeleccionarCarta,
                turnoActual: turnoActual,
                alturaCarta: alturaCarta,
                ocultarCartas: ocultarCartas,
              ),
              const SizedBox(height: 4),
              Text(
                tituloEquipoAbajo,
                style: EstilosTexto.subtitulo.copyWith(
                  color: Colores.secundario,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
