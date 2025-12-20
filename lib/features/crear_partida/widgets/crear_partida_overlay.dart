import 'dart:async';
import 'package:flutter/material.dart';

import '../controllers/controlador_crear_partida.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/errores.dart';
import '../../../app/rutas.dart';

/// Dialog overlay used on top of Home. Uses `ControladorCrearPartida` to
/// obtain host name and create the session. Designed to be small and
/// semitransparent over the Home screen.
class CrearPartidaOverlay extends StatefulWidget {
  const CrearPartidaOverlay({super.key});

  @override
  State<CrearPartidaOverlay> createState() => _CrearPartidaOverlayState();
}

class _CrearPartidaOverlayState extends State<CrearPartidaOverlay> {
  late final ControladorCrearPartida _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ControladorCrearPartida();
    _ctrl.cargarPerfil().catchError((_) {});
    _ctrl.addListener(_onCtrl);
  }

  void _onCtrl() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onCtrl);
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    try {
      final id = await _ctrl.crearSesion();
      if (!mounted) return;
      final rootNav = Navigator.of(context, rootNavigator: true);
      rootNav.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        rootNav.pushNamed(
          RutasApp.salaEspera,
          arguments: {
            'sessionId': id,
            'hostName': _ctrl.hostName,
            'maxPlayers': _ctrl.maxPlayers,
          },
        );
      });
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(ErroresRed.tiempoAgotado)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ErroresPartida.errorCrear}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      backgroundColor: Colores.transparente,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: Colores.primarioTransparente,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        TextoPartida.tituloCrearPartida,
                        style: EstilosTexto.tituloMedio.copyWith(
                          color: Colores.blanco,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${TextoPerfil.nombre}: ${_ctrl.hostName}',
                  style: EstilosTexto.subtitulo.copyWith(
                    color: Colores.blanco70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  TextoPartida.numeroJugadores,
                  style: EstilosTexto.subtitulo.copyWith(
                    color: Colores.blanco70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [2, 4, 6].map((n) {
                    final selected = _ctrl.maxPlayers == n;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          '$n',
                          style: EstilosTexto.boton.copyWith(
                            color: selected
                                ? Colores.blanco
                                : Colores.textoPrimario,
                          ),
                        ),
                        selected: selected,
                        selectedColor: Colores.primario,
                        backgroundColor: Colores.grisGoogle,
                        onSelected: (_) => setState(() => _ctrl.maxPlayers = n),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.secundario,
                      foregroundColor: Colores.textoPrimario,
                    ),
                    onPressed: _ctrl.cargando ? null : _crear,
                    child: _ctrl.cargando
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colores.blanco,
                            ),
                          )
                        : const Text(TextoPartida.btnCrearPartida),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
