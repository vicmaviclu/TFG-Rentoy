import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rentoy/core/constantes/cadenas.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';

import '../../../core/constantes/colores.dart';
import '../controllers/controlador_sala_espera.dart';
import '../../../models/usuario_model.dart';
import '../widgets/info_sala.dart';
import '../widgets/encabezado_equipos.dart';
import '../widgets/cuadricula_jugadores.dart';
import 'dart:async';
import '../widgets/acciones_sala.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/rutas.dart';

/// Pantalla de sala de espera.
class PantallaSalaEspera extends StatefulWidget {
  final String idSesion;
  final String nombreAnfitrion;
  final int maxJugadores;
  final bool conBot;

  const PantallaSalaEspera({
    super.key,
    required this.idSesion,
    required this.nombreAnfitrion,
    required this.maxJugadores,
    this.conBot = false,
  });

  @override
  State<PantallaSalaEspera> createState() => _PantallaSalaEsperaState();
}

class _PantallaSalaEsperaState extends State<PantallaSalaEspera> {
  late ControladorSalaEspera _controlador;

  late Stream<List<UsuarioModel>> _streamJugadores;
  late Stream<DatabaseEvent> _streamSesion;
  StreamSubscription? _subSesion;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorSalaEspera(servicio: ServicioRealtime());
    _streamJugadores = _controlador.streamJugadores(
      widget.idSesion,
      widget.maxJugadores,
    );
    _streamSesion = _controlador.streamEventoSesion(widget.idSesion);
    _subSesion = _streamSesion.listen((event) {
      if (!mounted) return;
      final val = event.snapshot.value as Map?;
      if (val != null && val['estado'] == TextoPartida.estadoJugando) {
        Navigator.of(context).pushReplacementNamed(
          RutasApp.partida,
          arguments: {
            'idSesion': widget.idSesion,
            'maxJugadores': widget.maxJugadores,
            'conBot': widget.conBot,
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _subSesion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaPantallaPrincipal(
      mostrarVolver: true,
      alVolver: () =>
          _manejarSalida(_controlador.esAnfitrion(widget.nombreAnfitrion)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info de la sala (Título, Anfitrión, PIN)
          InfoSala(
            streamSesion: _streamSesion,
            nombreAnfitrion: widget.nombreAnfitrion,
          ),

          const Divider(
            color: Colores.blanco12,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          // Títulos de Equipos
          const EncabezadoEquipos(),

          // Grid de Jugadores
          CuadriculaJugadores(
            streamJugadores: _streamJugadores,
            maxJugadores: widget.maxJugadores,
            alSeleccionarHueco: _manejarSeleccionHueco,
          ),

          // Botones de Acción
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder<DatabaseEvent>(
              stream: _streamSesion,
              builder: (context, snapshotSesion) {
                final valorSesion = snapshotSesion.hasData
                    ? snapshotSesion.data!.snapshot.value as Map?
                    : null;
                final pin = valorSesion?['pin']?.toString() ?? '';

                return StreamBuilder<List<UsuarioModel>>(
                  stream: _streamJugadores,
                  builder: (context, instantanea) {
                    final jugadores = instantanea.data ?? [];
                    final salaLlena = jugadores
                            .where((p) => p.nombreUsuario.isNotEmpty)
                            .length >=
                        widget.maxJugadores;

                    return AccionesSala(
                      salaLlena: salaLlena,
                      alInvitar: pin.isNotEmpty
                          ? () {
                              Share.share(
                                '${TextoPartida.mensajeInvitacion} $pin',
                              );
                            }
                          : null,
                      alEmpezar: salaLlena
                          ? () async {
                              try {
                                await _controlador.empezarPartida(widget.idSesion);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(TextoComun.errorInesperado),
                                  ),
                                );
                              }
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _manejarSeleccionHueco(int hueco) async {
    try {
      await _controlador.tomarHueco(widget.idSesion, hueco);
    } catch (e) {
      // Ignorar error/feedback visual
    }
  }

  Future<void> _manejarSalida(bool soyAnfitrion) async {
    if (soyAnfitrion) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(TextoPartida.cancelarPartida),
          content: const Text(TextoPartida.confirmarCancelarPartida),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(TextoComun.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(TextoComun.si),
            ),
          ],
        ),
      );
      if (confirmar == true) {
        try {
          await _controlador.cancelarSesion(widget.idSesion);
          if (!mounted) return;
          Navigator.of(context).pop();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(TextoComun.errorInesperado)),
          );
        }
      }
    } else {
      try {
        await _controlador.salirDeSesion(widget.idSesion);
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}
