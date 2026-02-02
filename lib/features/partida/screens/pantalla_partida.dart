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

  void _ejecutarLanzamiento(List<UsuarioModel> jugadores) {
    if (_cartaSeleccionadaIndex == null) return;

    final yo = jugadores.firstWhere(
      (u) => u.uid == _miUid,
      orElse: () =>
          UsuarioModel(uid: '', nombreUsuario: '', avatar: 0, mano: []),
    );

    // Null safety checks
    final mano = yo.mano;
    if (mano == null || mano.isEmpty || _cartaSeleccionadaIndex! >= mano.length)
      return;

    final cartaRaw = mano[_cartaSeleccionadaIndex!];
    if (cartaRaw is! Map) return;

    final cartaMap = Map<String, dynamic>.from(cartaRaw);

    _controlador
        .jugarCarta(widget.idSesion, _cartaSeleccionadaIndex!, cartaMap)
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
              SnackBar(content: Text("Error al lanzar carta: $e")),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // Por ahora solo Jugador 1 puede jugar.
    final bool esMiTurno = (_miKey == 'jugador 1');

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

            // Lógica para mostrar botón
            final mostrarBoton = esMiTurno && _cartaSeleccionadaIndex != null;

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
                    onLanzar: () => _ejecutarLanzamiento(jugadores),
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
        ),
      ),
    );
  }
}
