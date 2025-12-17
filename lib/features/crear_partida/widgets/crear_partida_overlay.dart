import 'package:flutter/material.dart';

import '../controllers/controlador_crear_partida.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../screens/pantalla_sala_espera.dart';

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
        rootNav.push(MaterialPageRoute(
          builder: (_) => PantallaSalaEspera(sessionId: id, hostName: _ctrl.hostName, maxPlayers: _ctrl.maxPlayers),
        ));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creando partida: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: Color.fromRGBO(247, 255, 249, 0.96),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Crear partida', style: EstilosTexto.tituloMedio)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Nombre: ${_ctrl.hostName}', style: EstilosTexto.subtitulo),
                const SizedBox(height: 12),
                Text('Número de jugadores', style: EstilosTexto.subtitulo),
                const SizedBox(height: 8),
                Row(children: [2, 4, 6].map((n) {
                  final selected = _ctrl.maxPlayers == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('$n', style: TextStyle(color: selected ? Colors.white : Colores.textoPrimario)),
                      selected: selected,
                      selectedColor: Colores.primario,
                      backgroundColor: Colores.grisGoogle,
                      onSelected: (_) => setState(() => _ctrl.maxPlayers = n),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colores.secundario, foregroundColor: Colors.black),
                    onPressed: _ctrl.cargando ? null : _crear,
                    child: _ctrl.cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Crear partida'),
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
