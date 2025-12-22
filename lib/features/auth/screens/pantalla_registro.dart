import 'package:flutter/material.dart';
import '../controllers/controlador_login.dart';
import '../widgets/formulario_registro.dart';
import '../../../app/rutas.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';

/// Pantalla de registro de usuarios (versión en español del archivo).
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  late final ControladorLogin _controller;

  @override
  void initState() {
    super.initState();
    _controller = ControladorLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaPantallaPrincipal(
      mostrarVolver: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            TextoAuth.tituloRegistro,
            style: EstilosTexto.titulo.copyWith(color: Colores.textoPrimario),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Form
          FormularioRegistro(controller: _controller),

          const SizedBox(height: 16),

          // Login Link
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(RutasApp.login),
            child: const Text(TextoAuth.yaTienesCuenta),
          ),
        ],
      ),
    );
  }
}
