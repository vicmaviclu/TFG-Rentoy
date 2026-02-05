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
  String? _miKey;
  int? _cartaSeleccionadaIndex;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorPartida(servicio: ServicioRealtime());
    _miUid = _controlador.obtenerMiUid();
    _streamJugadores = _controlador.streamJugadores(widget.idSesion);

    // Obtener mi key (jugador 1, etc)
    _controlador.obtenerMiKeyJugador(widget.idSesion).then((key) {
      if (mounted) {
        setState(() {
          _miKey = key;
        });
      }
    });
  }

  void _onSeleccionarCarta(int index) {
    setState(() {
      if (_cartaSeleccionadaIndex == index) {
        _cartaSeleccionadaIndex = null;
      } else {
        _cartaSeleccionadaIndex = index;
      }
    });
  }

  void _ejecutarLanzamiento() {
    if (_cartaSeleccionadaIndex == null) return;

    _controlador
        .jugarCarta(widget.idSesion, _cartaSeleccionadaIndex!)
        .then((_) {
          if (mounted) {
            setState(() {
              _cartaSeleccionadaIndex = null;
            });
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${TextoPartida.errorLanzarCarta}$e")),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      conScroll: false,
      mostrarTitulo: false,
      child: SizedBox.expand(
        child: StreamBuilder<int>(
          stream: _controlador.streamTurnoActual(widget.idSesion),
          builder: (context, snapshotTurno) {
            final turnoActual = snapshotTurno.data ?? 1;

            final bool esMiTurno = _controlador.esMiTurno(_miKey, turnoActual);

            return StreamBuilder<List<UsuarioModel>>(
              stream: _streamJugadores,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jugadores = snapshot.data ?? [];
                if (jugadores.isEmpty) {
                  return const Center(child: Text(TextoPartida.esperandoDatos));
                }

                // Usar controlador para organizar equipos
                final equipos = _controlador.organizarEquipos(
                  jugadores,
                  _miUid,
                );
                final equipoAbajo = equipos['abajo']!;
                final equipoArriba = equipos['arriba']!;

                // Determinar títulos según mi equipo
                // Si mi equipo es "equipo1" (porque soy par/impar adecuado), los rivales son "equipo2".
                // Pero `organizarEquipos` ya nos da [mi equipo, rivales].
                // Necesitamos saber QUÉ nombre ponerle.
                // Si estoy en equipo1, mi equipo se llama Equipo 1.
                bool soyEquipo1 = _controlador.soyEquipo1(jugadores, _miUid);

                String tituloEquipoArriba = soyEquipo1
                    ? TextoPartida.equipo2
                    : TextoPartida.equipo1;
                String tituloEquipoAbajo = soyEquipo1
                    ? TextoPartida.equipo1
                    : TextoPartida.equipo2;

                // Lógica para mostrar botón
                final mostrarBoton =
                    esMiTurno && _cartaSeleccionadaIndex != null;

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
                          ContenedorEquipo(
                            jugadores: equipoArriba,
                            miUid: _miUid,
                            // Rivales no seleccionan carta visualmente para mi
                            cartaSeleccionadaIndex: null,
                            onSeleccionar: null,
                            esMiTurno: false,
                          ),
                        ],
                      ),
                    ),

                    // Mesa en medio (Ocupa todo el espacio disponible)
                    Expanded(
                      child: MesaJuego(
                        controlador: _controlador,
                        idSesion: widget.idSesion,
                        mostrarBotonLanzar: mostrarBoton,
                        onLanzar: () => _ejecutarLanzamiento(),
                      ),
                    ),

                    // Mi Equipo (Abajo)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ContenedorEquipo(
                            jugadores: equipoAbajo,
                            miUid: _miUid,
                            cartaSeleccionadaIndex: _cartaSeleccionadaIndex,
                            onSeleccionar: _onSeleccionarCarta,
                            esMiTurno: esMiTurno,
                          ),
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
            );
          },
        ),
      ),
    );
  }
}
