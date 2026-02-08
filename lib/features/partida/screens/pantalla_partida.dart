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

            // Verificar si es mi turno
            final bool esMiTurno = _controlador.esMiTurno(_miKey, turnoActual);

            // --- STREAM 2: LISTA DE JUGADORES ---
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

                // Cargar y organizar jugadores en equipos
                final equipos = _controlador.organizarEquipos(
                  jugadores,
                  _miUid,
                );
                final equipoAbajo = equipos['abajo']!;
                final equipoArriba = equipos['arriba']!;

                // Determinar títulos de equipos según mi equipo
                bool soyEquipo1 = _controlador.soyEquipo1(jugadores, _miUid);

                String tituloEquipoArriba = soyEquipo1
                    ? TextoPartida.equipo2
                    : TextoPartida.equipo1;
                String tituloEquipoAbajo = soyEquipo1
                    ? TextoPartida.equipo1
                    : TextoPartida.equipo2;

                // Lógica para mostrar botón de lanzar (solo si es mi turno y hay carta seleccionada)
                final mostrarBoton =
                    esMiTurno && _cartaSeleccionadaIndex != null;

                // --- STREAM 3: DATOS DE LA PARTIDA (Puntos, Estado) ---
                return StreamBuilder<DatabaseEvent>(
                  stream: _controlador.streamPartida(widget.idSesion),
                  builder: (context, snapshotSesion) {
                    // --- EXTRACCIÓN DE PUNTOS ---
                    int p1 = 0;
                    int p2 = 0;
                    if (snapshotSesion.hasData &&
                        snapshotSesion.data!.snapshot.value != null) {
                      final val = snapshotSesion.data!.snapshot.value;
                      if (val is Map) {
                        // --- VERIFICAR FIN DE PARTIDA ---
                        if (val['estado'] == 'finalizada' &&
                            mounted &&
                            !_navegandoAFin) {
                          // Navegar a pantalla de resultado
                          final ganador = (val['ganador'] is int)
                              ? val['ganador']
                              : int.tryParse(val['ganador'].toString()) ?? 0;

                          // Determinar si gané
                          bool victoria = false;
                          if (ganador == 1 && soyEquipo1) victoria = true;
                          if (ganador == 2 && !soyEquipo1) victoria = true;

                          // Evitar múltiples navegaciones
                          _navegandoAFin = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => PantallaFinPartida(
                                  victoria: victoria,
                                  puntosEquipo1: p1,
                                  puntosEquipo2: p2,
                                  onVolver: () {
                                    // Navegar a home
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  },
                                ),
                              ),
                            );
                          });
                        }

                        if (val['puntos'] is Map) {
                          p1 = (val['puntos']['equipo1'] is int)
                              ? val['puntos']['equipo1']
                              : 0;
                          p2 = (val['puntos']['equipo2'] is int)
                              ? val['puntos']['equipo2']
                              : 0;
                        }
                      }
                    }

                    // --- CONSTRUCCIÓN DEL LAYOUT DE PANTALLA ---
                    return Column(
                      children: [
                        // --- MARCADOR DE PUNTOS ---
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                          child: TableroPuntos(
                            puntosEquipo1: p1,
                            puntosEquipo2: p2,
                          ),
                        ),

                        // --- EQUIPO RIVAL (ARRIBA) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tituloEquipoArriba,
                                style: EstilosTexto.subtitulo.copyWith(
                                  color: Colores.blanco70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ContenedorEquipo(
                                jugadores: equipoArriba,
                                miUid: _miUid,
                                cartaSeleccionadaIndex: null,
                                onSeleccionar: null,
                                esMiTurno: false,
                              ),
                            ],
                          ),
                        ),

                        // --- MESA DE JUEGO (CENTRO) ---
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 310),
                              child: SizedBox(
                                width: double.infinity,
                                child: MesaJuego(
                                  controlador: _controlador,
                                  idSesion: widget.idSesion,
                                  mostrarBotonLanzar: mostrarBoton,
                                  onLanzar: () => _ejecutarLanzamiento(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // --- MI EQUIPO (ABAJO) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ContenedorEquipo(
                                jugadores: equipoAbajo,
                                miUid: _miUid,
                                cartaSeleccionadaIndex: _cartaSeleccionadaIndex,
                                onSeleccionar: _onSeleccionarCarta,
                                esMiTurno: esMiTurno,
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
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
