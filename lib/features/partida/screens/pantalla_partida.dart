import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/errores.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../partida/controllers/controlador_partida.dart';
import '../../partida/widgets/contenedor_equipo.dart';
import '../../partida/widgets/mesa_juego.dart';
import '../../../models/usuario_model.dart';
import '../../../core/constantes/textos.dart';
import 'pantalla_fin_partida.dart';
import '../widgets/tablero_puntos.dart';

import 'package:firebase_database/firebase_database.dart';

/// Pantalla principal del juego donde se desarrolla la partida.
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
  /// Controlador de la lógica de partida
  late ControladorPartida _controlador;

  late Stream<List<UsuarioModel>> _streamJugadores;
  late String _miUid;
  String? _miKey;
  int? _cartaSeleccionadaIndex;
  bool _navegandoAFin = false;
  bool _ocultarCartas = false;

  @override
  void initState() {
    super.initState();
    // --- INICIALIZACIÓN DE CONTROLADOR Y STREAMS ---
    _controlador = ControladorPartida(servicio: ServicioRealtime());
    _miUid = _controlador.obtenerMiUid();
    _streamJugadores = _controlador.streamJugadores(widget.idSesion);

    // Obtener mi key de jugador (jugador1, jugador2, etc)
    _controlador.obtenerMiKeyJugador(widget.idSesion).then((key) {
      if (mounted) {
        setState(() {
          _miKey = key;
        });
      }
    });
  }

  /// Maneja la selección/deselección de una carta
  void _onSeleccionarCarta(int index) {
    setState(() {
      if (_cartaSeleccionadaIndex == index) {
        _cartaSeleccionadaIndex = null;
      } else {
        _cartaSeleccionadaIndex = index;
      }
    });
  }

  /// Ejecuta el lanzamiento de la carta seleccionada
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
              SnackBar(content: Text("${ErroresPartida.errorLanzarCarta}$e")),
            );
          }
        });
  }

  @override
  @override
  Widget build(BuildContext context) {
    // --- LAYOUT PRINCIPAL CON FONDO ---
    return PaginaFondo(
      conScroll: false,
      mostrarTitulo: false,
      child: SizedBox.expand(
        // --- STREAM 1: TURNO ACTUAL ---
        child: StreamBuilder<int>(
          stream: _controlador.streamTurnoActual(widget.idSesion),
          builder: (context, snapshotTurno) {
            final turnoActual = snapshotTurno.data ?? 1;
            final bool esMiTurno = _controlador.esMiTurno(_miKey, turnoActual);

            // --- STREAM 2: JUGADORES ---
            return StreamBuilder<List<UsuarioModel>>(
              stream: _streamJugadores,
              builder: (context, snapshotJugadores) {
                if (snapshotJugadores.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final jugadores = snapshotJugadores.data ?? [];
                if (jugadores.isEmpty) {
                  return const Center(child: Text(TextoPartida.esperandoDatos));
                }

                // --- STREAM 3: DATOS DE PARTIDA ---
                return StreamBuilder<DatabaseEvent>(
                  stream: _controlador.streamPartida(widget.idSesion),
                  builder: (context, snapshotPartida) {
                    if (!snapshotPartida.hasData ||
                        snapshotPartida.data?.snapshot.value == null) {
                      // Si no hay datos, esperamos o mostramos carga
                      return const SizedBox.shrink();
                    }

                    final val = snapshotPartida.data!.snapshot.value;
                    if (val is Map) {
                      _gestionarNavegacionFinPartida(val, jugadores);
                    }

                    return _VistaPartida(
                      jugadores: jugadores,
                      miUid: _miUid,
                      esMiTurno: esMiTurno,
                      cartaSeleccionadaIndex: _cartaSeleccionadaIndex,
                      ocultarCartas: _ocultarCartas,
                      datosPartida: (val is Map) ? val : {},
                      controlador: _controlador,
                      idSesion: widget.idSesion,
                      onSeleccionarCarta: _onSeleccionarCarta,
                      onLanzarCarta: _ejecutarLanzamiento,
                      onCambiarCartas: () {
                        setState(() {
                          _ocultarCartas = !_ocultarCartas;
                        });
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _gestionarNavegacionFinPartida(Map val, List<UsuarioModel> jugadores) {
    if (val['estado'] == 'finalizada' && mounted && !_navegandoAFin) {
      final ganador = (val['ganador'] is int)
          ? val['ganador']
          : int.tryParse(val['ganador'].toString()) ?? 0;

      bool soyEquipo1 = _controlador.soyEquipo1(jugadores, _miUid);
      bool victoria =
          (ganador == 1 && soyEquipo1) || (ganador == 2 && !soyEquipo1);

      // Puntos
      int p1 = 0;
      int p2 = 0;
      if (val['puntos'] is Map) {
        final pts = val['puntos'];
        p1 = (pts['equipo1'] is int) ? pts['equipo1'] : 0;
        p2 = (pts['equipo2'] is int) ? pts['equipo2'] : 0;
      }

      _navegandoAFin = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PantallaFinPartida(
              victoria: victoria,
              puntosEquipo1: p1,
              puntosEquipo2: p2,
              onVolver: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      });
    }
  }
}

class _VistaPartida extends StatelessWidget {
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

  const _VistaPartida({
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

    final double screenHeight = MediaQuery.of(context).size.height;
    final double alturaCarta = (screenHeight * 0.19).clamp(100.0, 220.0);

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
                esMiTurno: false,
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
                esMiTurno: esMiTurno,
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
