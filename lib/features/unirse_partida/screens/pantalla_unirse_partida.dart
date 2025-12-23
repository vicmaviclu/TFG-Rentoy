import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';
import '../controllers/controlador_unirse_partida.dart';
import '../../../app/rutas.dart';

class PantallaUnirsePartida extends StatefulWidget {
  const PantallaUnirsePartida({super.key});

  @override
  State<PantallaUnirsePartida> createState() => _PantallaUnirsePartidaState();
}

class _PantallaUnirsePartidaState extends State<PantallaUnirsePartida> {
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

  Future<void> _unirse() async {
    final pin = _pinCtrl.text.trim();
    if (pin.isEmpty) return;

    try {
      final datos = await _ctrl.unirsePorPin(pin);
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
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
    return PlantillaPantallaPrincipal(
      mostrarVolver: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TextoPartida.tituloUnirsePartida,
              style: EstilosTexto.tituloMedio.copyWith(
                color: Colores.textoPrimario,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.secundario,
                  foregroundColor: Colores.textoPrimario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _ctrl.cargando ? null : _unirse,
                child: _ctrl.cargando
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colores.textoPrimario,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        TextoPartida.btnUnirsePartida,
                        style: EstilosTexto.boton,
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
