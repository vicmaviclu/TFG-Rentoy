import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../partida/controllers/controlador_partida.dart';
import '../../partida/widgets/contenedor_equipo.dart';
import '../../partida/widgets/mesa_juego.dart';
import '../../../models/usuario_model.dart';
import '../../../core/constantes/textos.dart';

class PantallaPartida extends StatefulWidget {
  final String idSesion;
  final int maxJugadores;

  const PantallaPartida({
    super.key,
    required this.idSesion,
    required this.maxJugadores,
  });

  @override
  State<PantallaPartida> createState() => _PantallaPartidaState();
}

class _PantallaPartidaState extends State<PantallaPartida> {
  late ControladorPartida _controlador;
  late Stream<List<UsuarioModel>> _streamJugadores;
  late String _miUid;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorPartida(servicio: ServicioRealtime());
    _miUid = _controlador.obtenerMiUid();
    _streamJugadores = _controlador.streamJugadores(widget.idSesion);
  }

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      conScroll: false,
      mostrarTitulo: false,
      child: SizedBox.expand(
        child: StreamBuilder<List<UsuarioModel>>(
          stream: _streamJugadores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final jugadores = snapshot.data ?? [];
            if (jugadores.isEmpty) {
              return const Center(child: Text(TextoPartida.esperandoDatos));
            }

            // Separar equipos
            List<UsuarioModel> equipo1 = [];
            List<UsuarioModel> equipo2 = [];
            int miIndice = -1;

            for (int i = 0; i < jugadores.length; i++) {
              if (jugadores[i].uid == _miUid) {
                miIndice = i;
              }
              // Lógica par/impar para equipos
              if (i % 2 == 0) {
                equipo1.add(jugadores[i]);
              } else {
                equipo2.add(jugadores[i]);
              }
            }

            // Determinar qué equipo va abajo (mi equipo)
            bool soyEquipo1 = (miIndice != -1 && miIndice % 2 == 0);

            // Si no me encuentro (espectador o error), defecto Equipo 1 abajo
            List<UsuarioModel> equipoAbajo = soyEquipo1 ? equipo1 : equipo2;
            List<UsuarioModel> equipoArriba = soyEquipo1 ? equipo2 : equipo1;

            String tituloEquipoArriba = soyEquipo1
                ? TextoPartida.equipo2
                : TextoPartida.equipo1;
            String tituloEquipoAbajo = soyEquipo1
                ? TextoPartida.equipo1
                : TextoPartida.equipo2;

            return Column(
              children: [
                // Equipo Rival (Arriba)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        tituloEquipoArriba,
                        style: EstilosTexto.subtitulo.copyWith(
                          color: Colores.blanco70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ContenedorEquipo(jugadores: equipoArriba, miUid: _miUid),
                    ],
                  ),
                ),

                const Spacer(),

                // Mesa en medio
                const Expanded(flex: 2, child: Center(child: MesaJuego())),

                const Spacer(),

                // Mi Equipo (Abajo)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ContenedorEquipo(jugadores: equipoAbajo, miUid: _miUid),
                      const SizedBox(height: 8),
                      Text(
                        tituloEquipoAbajo,
                        style: EstilosTexto.subtitulo.copyWith(
                          color: Colores.secundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
