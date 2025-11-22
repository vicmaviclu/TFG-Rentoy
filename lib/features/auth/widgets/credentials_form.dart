import 'package:flutter/material.dart';
import '../controllers/controlador_login.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';

/// Credentials form for sign-in using email + password.
///
/// Presentation-only widget that delegates authentication actions to
/// `ControladorLogin` provided by the parent screen.
class CredentialsForm extends StatefulWidget {
  final ControladorLogin controller;

  const CredentialsForm({required this.controller, super.key});

  @override
  State<CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<CredentialsForm> {
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
              decoration: InputDecoration(labelText: AppStrings.emailHint, filled: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.controladorContrasena,
              decoration: InputDecoration(labelText: AppStrings.passwordHint, filled: true),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: controller.cargando
                    ? null
                    : () async {
                        final err = await controller.iniciarSesionConEmail();
                        if (err != null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                        }
                      },
                child: controller.cargando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : Text(AppStrings.loginTitle, style: AppTextStyles.subheading),
              ),
            ),
          ],
        );
      },
    );
  }
}
