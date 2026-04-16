import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/errores.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../partida/controllers/controlador_partida.dart';
import '../../../models/usuario_model.dart';
import '../widgets/overlay_envite.dart';
import 'pantalla_fin_partida.dart';
import '../widgets/vista_partida.dart';
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
  bool _envitePendienteLocal = false;

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

    // Bloquear si hay envite
    if (_envitePendienteLocal) return;

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

                    final datosPartida = (val is Map) ? val : {};

                    // --- LÓGICA DE BLOQUEO POR ENVITE ---
                    Map? enviteData;
                    int puntosActuales = 1;
                    if (datosPartida['rondas'] is Map) {
                      final rondas = datosPartida['rondas'] as Map;
                      final actual = rondas['actual'];
                      if (actual != null && rondas[actual.toString()] is Map) {
                        final rondaData = rondas[actual.toString()] as Map;
                        enviteData = rondaData['envite'] as Map?;
                        puntosActuales = (rondaData['puntos'] as int?) ?? 1;
                      }
                    }

                    final envitePendiente =
                        enviteData != null &&
                        enviteData['estado'] == 'pendiente';
                    final respondoYo =
                        envitePendiente &&
                        enviteData['quien_responde'] == _miKey;

                    // Comprobar la alternancia de cantos
                    int? ultimoEquipoCanto;
                    if (datosPartida['rondas'] is Map) {
                      final rondas = datosPartida['rondas'] as Map;
                      final actual = rondas['actual'];
                      if (actual != null && rondas[actual.toString()] is Map) {
                        final rondaData = rondas[actual.toString()] as Map;
                        if (rondaData['ultimo_equipo_canto'] != null) {
                          ultimoEquipoCanto =
                              rondaData['ultimo_equipo_canto'] as int;
                        }
                      }
                    }

                    // Sincronizar estado local para el onSeleccionarCarta / _ejecutarLanzamiento
                    _envitePendienteLocal = envitePendiente;

                    bool soyEquipo1 = _controlador.soyEquipo1(
                      jugadores,
                      _miUid,
                    );
                    int miEquipo = soyEquipo1 ? 1 : 2;

                    // Todos pueden cantar si es su turno.
                    // el equipo 1 no puede volver a cantar hasta que cante el 2.

                    void presionarCantar() {
                      if (envitePendiente) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              TextoPartida.envitePendientePrecaucion,
                            ),
                          ),
                        );
                        return;
                      }
                      if (!esMiTurno) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(TextoPartida.errorTurnoCantar),
                          ),
                        );
                        return;
                      }
                      if (ultimoEquipoCanto == miEquipo) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(TextoPartida.errorEquipoYaCanto),
                          ),
                        );
                        return;
                      }

                      final messenger = ScaffoldMessenger.of(context);

                      _controlador
                          .cantar(widget.idSesion)
                          .then((_) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(TextoPartida.enviteEnviado),
                              ),
                            );
                          })
                          .catchError((e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${ErroresPartida.errorCantar}$e",
                                ),
                              ),
                            );
                          });
                    }

                    return Stack(
                      children: [
                        VistaPartida(
                          jugadores: jugadores,
                          miUid: _miUid,
                          esMiTurno: esMiTurno,
                          cartaSeleccionadaIndex: _cartaSeleccionadaIndex,
                          ocultarCartas: _ocultarCartas,
                          datosPartida: datosPartida,
                          controlador: _controlador,
                          idSesion: widget.idSesion,
                          onSeleccionarCarta: envitePendiente
                              ? (i) {}
                              : _onSeleccionarCarta,
                          onLanzarCarta: envitePendiente
                              ? () {}
                              : _ejecutarLanzamiento,
                          onCambiarCartas: () {
                            setState(() {
                              _ocultarCartas = !_ocultarCartas;
                            });
                          },
                          onCantar: presionarCantar,
                        ),

                        // --- OVERLAY DE ENVITE ---
                        if (respondoYo)
                          OverlayEnvite(
                            puntosActuales: puntosActuales,
                            onNoQuiero: () => _controlador.rechazarCantar(
                              widget.idSesion,
                            ),
                            onQuiero: () => _controlador.responderCantar(
                              widget.idSesion,
                              true,
                            ),
                            onReenvitar: () => _controlador.responderCantar(
                              widget.idSesion,
                              false,
                            ),
                          ),
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
