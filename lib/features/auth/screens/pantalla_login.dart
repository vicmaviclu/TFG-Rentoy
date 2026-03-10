import 'package:flutter/material.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';
import '../controllers/controlador_login.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../app/rutas.dart';
import '../widgets/formulario_login.dart';
import '../widgets/boton_google.dart';

/// Pantalla de inicio de sesión.
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
    return PlantillaPantallaPrincipal(
      mostrarVolver: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 45),
          Text(
            TextoComun.nombreApp,
            style: EstilosTexto.titulo.copyWith(color: Colores.textoPrimario),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            TextoComun.subtitulo,
            style: EstilosTexto.cuerpo.copyWith(color: Colores.textoSecundario),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Formulario
          FormularioLogin(controller: _controller),

          const SizedBox(height: 12),
          Text(
            'o',
            style: EstilosTexto.subtitulo.copyWith(
              color: Colores.textoSecundario,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Botón de Google
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Center(
                child: BotonGoogle(
                  isLoading: _controller.cargando,
                  onPressed: () async {
                    final err = await _controller.iniciarSesionConGoogle();
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  fullWidth: true,
                  label: TextoAuth.continuarConGoogle,
                  height: 40,
                  iconSize: 24,
                  textStyle: EstilosTexto.boton,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Enlace al registro
          TextButton(
            onPressed: _controller.cargando
                ? null
                : () => Navigator.of(context).pushNamed(RutasApp.registro),
            child: const Text(TextoAuth.noTienesCuenta),
          ),
        ],
      ),
    );
  }
}
