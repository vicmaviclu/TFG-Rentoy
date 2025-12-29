import 'package:flutter/material.dart';

import 'boton_google.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../controllers/controlador_login.dart';
import 'formulario_login.dart';
import '../../../core/widgets/encabezado_app.dart';
import '../../../app/rutas.dart';
import 'tarjeta_auth.dart';

/// Tarjeta de login completa.
class TarjetaLogin extends StatelessWidget {
  const TarjetaLogin({super.key, required this.controller, required this.size});

  final ControladorLogin controller;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return TarjetaAuth(
      size: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado de la aplicación
          const EncabezadoApp(),
          const SizedBox(height: 6),
          // Formulario de login
          FormularioLogin(controller: controller),
          const SizedBox(height: 5),
          Text(
            'o',
            style: EstilosTexto.subtitulo.copyWith(
              color: Colores.textoSecundario,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Center(
                // Botón de Google
                child: BotonGoogle(
                  isLoading: controller.cargando,
                  onPressed: () async {
                    final err = await controller.iniciarSesionConGoogle();
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  fullWidth: false,
                  label: TextoAuth.continuarConGoogle,
                  height: 54,
                  iconSize: 30,
                  textStyle: EstilosTexto.boton,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          // Enlace a registro
          TextButton(
            onPressed: controller.cargando
                ? null
                : () => Navigator.of(context).pushNamed(RutasApp.registro),
            child: const Text(TextoAuth.noTienesCuenta),
          ),
        ],
      ),
    );
  }
}
