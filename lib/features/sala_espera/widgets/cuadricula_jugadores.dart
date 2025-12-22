import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';
import 'tarjeta_jugador.dart';

class CuadriculaJugadores extends StatelessWidget {
  final Stream<List<UsuarioModel>> streamJugadores;
  final int maxJugadores;
  final Function(int) alSeleccionarHueco;

  const CuadriculaJugadores({
    super.key,
    required this.streamJugadores,
    required this.maxJugadores,
    required this.alSeleccionarHueco,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UsuarioModel>>(
      stream: streamJugadores,
      builder: (context, instantanea) {
        if (instantanea.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final jugadores =
            instantanea.data ??
            List<UsuarioModel>.filled(
              maxJugadores,
              UsuarioModel(uid: '', email: '', nombreUsuario: '', avatar: 1),
            );

        final int filas = (maxJugadores / 2).ceil();

        return Column(
          children: List.generate(filas, (indiceFila) {
            final indice1 = indiceFila * 2;
            final indice2 = indice1 + 1;

            final info1 = indice1 < jugadores.length
                ? jugadores[indice1]
                : null;
            final info2 = indice2 < jugadores.length
                ? jugadores[indice2]
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 12, right: 12),
              child: SizedBox(
                height: 60, // Altura reducida
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TarjetaJugador(
                        nombre: info1?.nombreUsuario,
                        uid: info1?.uid,
                        indiceAvatar: info1?.avatar,
                        esAnfitrion: indice1 == 0,
                        alPulsar: () => alSeleccionarHueco(indice1 + 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TarjetaJugador(
                        nombre: info2?.nombreUsuario,
                        uid: info2?.uid,
                        indiceAvatar: info2?.avatar,
                        esAnfitrion: indice2 == 0,
                        alPulsar: () => alSeleccionarHueco(indice2 + 1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
