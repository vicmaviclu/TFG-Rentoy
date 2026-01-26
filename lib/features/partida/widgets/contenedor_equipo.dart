import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';
import 'avatar_jugador_partida.dart';

class ContenedorEquipo extends StatelessWidget {
  final List<UsuarioModel> jugadores;
  final String miUid;

  const ContenedorEquipo({
    super.key,
    required this.jugadores,
    required this.miUid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: jugadores.map((usuario) {
        return AvatarJugadorPartida(
          nombre: usuario.nombreUsuario,
          avatar: usuario.avatar,
          esMiJugador: usuario.uid == miUid,
        );
      }).toList(),
    );
  }
}
