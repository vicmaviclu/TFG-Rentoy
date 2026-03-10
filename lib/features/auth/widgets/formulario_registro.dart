import 'package:flutter/material.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/errores.dart';
import '../controllers/controlador_login.dart';

/// Formulario de registro de usuario.
class FormularioRegistro extends StatefulWidget {
  final ControladorLogin controller;

  const FormularioRegistro({required this.controller, super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _confirmPasswordController = TextEditingController();
  final _usuarioController = TextEditingController();

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _usuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de correo electrónico
            TextField(
              controller: widget.controller.controladorCorreo,
              decoration: InputDecoration(
                labelText: TextoAuth.correoHint,
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 8),
            // Campo de nombre de usuario
            TextField(
              controller: _usuarioController,
              decoration: InputDecoration(
                labelText: TextoPerfil.nombreUsuario,
                filled: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            // Campo de contraseña
            TextField(
              controller: widget.controller.controladorContrasena,
              decoration: InputDecoration(
                labelText: TextoAuth.contrasenaHint,
                filled: true,
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 8),
            // Campo de confirmar contraseña
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: TextoAuth.confirmarContrasena,
                filled: true,
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            // Botón de registro
            SizedBox(
              width: 100,
              height: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.secundario,
                  foregroundColor: Colores.textoPrimario,
                  textStyle: EstilosTexto.boton,
                  elevation: 4,
                ),
                onPressed: widget.controller.cargando
                    ? null
                    : _performRegistration,
                child: widget.controller.cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(TextoAuth.registrarse),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRegistration() async {
    // Transferir el valor del nombre de usuario al controlador principal
    widget.controller.controladorUsuario.text = _usuarioController.text.trim();
    if (_confirmPasswordController.text !=
        widget.controller.controladorContrasena.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ErroresValidacion.contrasenasNoCoinciden)),
      );
      return;
    }

    final err = await widget.controller.registrarConEmail();
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(TextoAuth.registroCompletado)),
      );
      Navigator.of(context).pop();
    }
  }
}
