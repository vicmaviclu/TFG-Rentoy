import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';
import 'avatar_jugador_partida.dart';

class ContenedorEquipo extends StatelessWidget {
  final List<UsuarioModel> jugadores;
  final String miUid;
  // New props for selection
  final int? cartaSeleccionadaIndex;
  final Function(int)? onSeleccionar;
  final bool esMiTurno;

  const ContenedorEquipo({
    super.key,
    required this.jugadores,
    required this.miUid,
    this.cartaSeleccionadaIndex,
    this.onSeleccionar,
    this.esMiTurno = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: jugadores.map((usuario) {
        return Expanded(
          child: AvatarJugadorPartida(
            nombre: usuario.nombreUsuario,
            avatar: usuario.avatar,
            mano: usuario.mano,
            esMiJugador: usuario.uid == miUid,
            cartaSeleccionadaIndex: cartaSeleccionadaIndex,
            onSeleccionar: onSeleccionar,
            esMiTurno: esMiTurno,
          ),
        );
      }).toList(),
    );
  }
}
