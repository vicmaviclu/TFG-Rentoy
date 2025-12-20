import 'package:flutter/material.dart';
import '../controllers/controlador_login.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';

/// Formulario para inicio de sesión (correo + contraseña).
class FormularioLogin extends StatefulWidget {
  final ControladorLogin controller;

  const FormularioLogin({required this.controller, super.key});

  @override
  State<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends State<FormularioLogin> {
  ControladorLogin get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            TextField(
              controller: controller.controladorCorreo,
              decoration: InputDecoration(
                labelText: TextoAuth.correoHint,
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.controladorContrasena,
              decoration: InputDecoration(
                labelText: TextoAuth.contrasenaHint,
                filled: true,
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.cargando ? null : _performLogin,
                child: controller.cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        TextoAuth.tituloLogin,
                        style: EstilosTexto.cuerpoNegrita,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogin() async {
    final err = await controller.iniciarSesionConEmail();
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}
