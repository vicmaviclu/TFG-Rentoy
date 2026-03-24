import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';
import 'avatar_jugador_partida.dart';

/// Fila inferior de avatares del equipo local con el jugador actual centrado.
class FilaAvataresEquipoInferior extends StatelessWidget {
  final UsuarioModel? miJugador;
  final List<UsuarioModel> companeros;
  final String miUid;
  final int turnoActual;
  final double alturaCarta;

  const FilaAvataresEquipoInferior({
    super.key,
    required this.miJugador,
    required this.companeros,
    required this.miUid,
    required this.turnoActual,
    required this.alturaCarta,
  });

  @override
  Widget build(BuildContext context) {
    if (miJugador == null && companeros.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<UsuarioModel> ladoIzquierdo = [];
    final List<UsuarioModel> ladoDerecho = [];
    for (int i = 0; i < companeros.length; i++) {
      if (i.isEven) {
        ladoIzquierdo.add(companeros[i]);
      } else {
        ladoDerecho.add(companeros[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: ladoIzquierdo
                .map(
                  (jugador) => Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: AvatarJugadorPartida(
                      jugador: jugador,
                      esMiJugador: false,
                      esSuTurno: jugador.esSuTurno(turnoActual),
                      alturaCarta: alturaCarta,
                      mostrarMano: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (miJugador != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AvatarJugadorPartida(
              jugador: miJugador!,
              esMiJugador: miJugador!.uid == miUid,
              esSuTurno: miJugador!.esSuTurno(turnoActual),
              alturaCarta: alturaCarta,
              mostrarMano: false,
            ),
          ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ladoDerecho
                .map(
                  (jugador) => Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: AvatarJugadorPartida(
                      jugador: jugador,
                      esMiJugador: false,
                      esSuTurno: jugador.esSuTurno(turnoActual),
                      alturaCarta: alturaCarta,
                      mostrarMano: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
