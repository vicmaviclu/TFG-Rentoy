import 'package:flutter/material.dart';
import '../controllers/controlador_login.dart';
import '../widgets/formulario_registro.dart';
import '../../../core/widgets/encabezado_app.dart';
import '../../../app/rutas.dart';
import '../widgets/tarjeta_auth.dart';
import '../../../core/widgets/pagina_fondo.dart';
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
    final size = MediaQuery.of(context).size;

    return PaginaFondo(
      showTitle: true,
      child: TarjetaAuth(
        size: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EncabezadoApp(),
            const SizedBox(height: 16),
            FormularioRegistro(controller: _controller),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(RutasApp.login),
              child: const Text(Cadenas.yaTienesCuenta),
            ),
          ],
        ),
      ),
    );
  }
}
