import 'package:flutter/material.dart';

import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/widgets/contenedor_principal.dart';
import '../../../app/rutas.dart';
import '../controllers/controlador_unirse_partida.dart';

/// Contenido del modal para unirse a partida.
class UnirsePartidaOverlay extends StatefulWidget {
  const UnirsePartidaOverlay({super.key});

  @override
  State<UnirsePartidaOverlay> createState() => _UnirsePartidaOverlayState();
}

class _UnirsePartidaOverlayState extends State<UnirsePartidaOverlay> {
  late final ControladorUnirsePartida _ctrl;
  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = ControladorUnirsePartida();
    _ctrl.cargarPerfil().catchError((_) {});
    _ctrl.addListener(_onCtrl);
  }

  void _onCtrl() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onCtrl);
    _ctrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarYUnirse() async {
    final pin = _pinCtrl.text.trim();
    if (pin.isEmpty) return;

    try {
      // Usamos el controlador para lógica de negocio
      final datos = await _ctrl.unirsePorPin(pin);
      if (!mounted) return;

      // Cerramos el overlay
      Navigator.of(context).pop();

      // Navegamos a la sala de espera
      // Usamos pushNamed sobre el root navigator o el que corresponda
      Navigator.of(context).pushNamed(
        RutasApp.salaEspera,
        arguments: {
          'idSesion': datos['id'],
          'nombreAnfitrion': datos['anfitrion'],
          'maxJugadores': datos['maxJugadores'],
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
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
        child: ContenedorPrincipal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título y botón cerrar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      TextoPartida.tituloUnirsePartida,
                      style: EstilosTexto.tituloMedio.copyWith(
                        color: Colores.blanco,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colores.blanco),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campo para introducir PIN
              TextField(
                controller: _pinCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colores.superficie,
                  hintText: TextoPartida.introducePin,
                  hintStyle: const TextStyle(color: Colores.textoSecundario),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colores.textoPrimario,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Botón para buscar y unirse
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.secundario,
                    foregroundColor: Colores.textoPrimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _ctrl.cargando ? null : _buscarYUnirse,
                  icon: _ctrl.cargando
                      ? const SizedBox.shrink()
                      : const Icon(Icons.search),
                  label: _ctrl.cargando
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colores.textoPrimario,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          TextoPartida.btnBuscar,
                          style: EstilosTexto.boton,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
