import 'package:flutter/material.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../controllers/controlador_login.dart';

/// Formulario para la pantalla de registro (versión en español).
class FormularioRegistro extends StatefulWidget {
  final ControladorLogin controller;

  const FormularioRegistro({required this.controller, super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _confirmPasswordController.dispose();
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
            TextField(
              controller: widget.controller.controladorCorreo,
              decoration: InputDecoration(labelText: Cadenas.correoHint, filled: true),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.controller.controladorContrasena,
              decoration: InputDecoration(labelText: Cadenas.contrasenaHint, filled: true),
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: Cadenas.confirmarContrasena, filled: true),
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.controller.cargando ? null : _performRegistration,
                child: widget.controller.cargando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                    : const Text(Cadenas.registrarse, style: EstilosTexto.cuerpoNegrita),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRegistration() async {
    if (_confirmPasswordController.text != widget.controller.controladorContrasena.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Cadenas.contrasenasNoCoinciden)));
      return;
    }

    final err = await widget.controller.registrarConEmail();
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Cadenas.registroCompletado)));
      Navigator.of(context).pop();
    }
  }
}
