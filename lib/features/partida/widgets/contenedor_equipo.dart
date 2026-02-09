import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';
import 'avatar_jugador_partida.dart';

/// Contenedor que muestra los jugadores de un equipo con sus cartas.
class ContenedorEquipo extends StatelessWidget {
  /// Lista de jugadores del equipo
  final List<UsuarioModel> jugadores;

  /// UID del usuario actual
  final String miUid;

  /// Índice de la carta seleccionada
  final int? cartaSeleccionadaIndex;

  /// Función para seleccionar carta
  final Function(int)? onSeleccionar;

  /// Si es el turno del jugador
  final bool esMiTurno;

  /// Altura deseada para las cartas
  final double alturaCarta;

  const ContenedorEquipo({
    super.key,
    required this.jugadores,
    required this.miUid,
    this.cartaSeleccionadaIndex,
    this.onSeleccionar,
    this.esMiTurno = false,
    this.alturaCarta = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    // --- FILA DE AVATARES DE JUGADORES DEL EQUIPO ---
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      // Generar avatar para cada jugador del equipo
      children: jugadores.map((usuario) {
        return Expanded(
          child: AvatarJugadorPartida(
            jugador: usuario,
            esMiJugador: usuario.uid == miUid,
            cartaSeleccionadaIndex: cartaSeleccionadaIndex,
            onSeleccionar: onSeleccionar,
            esMiTurno: esMiTurno,
            alturaCarta: alturaCarta,
          ),
        );
      }).toList(),
    );
  }
}
