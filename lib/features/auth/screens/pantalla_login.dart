import 'package:flutter/material.dart';

// Header and common page background provided by core widgets
import '../../../core/widgets/pagina_fondo.dart';
import '../controllers/controlador_login.dart';
import '../widgets/tarjeta_login.dart';

/// Pantalla de inicio de sesión (presentación y navegación).
///
/// Esta pantalla delega la parte visual a widgets en
/// `features/auth/widgets/` y mantiene la lógica de navegación y
/// controladores.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
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
      child: TarjetaLogin(controller: _controller, size: size),
    );
  }
} 
