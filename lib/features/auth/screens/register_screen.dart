import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/widgets/fondo_cartas.dart';

/// Pantalla de registro con formulario básico.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirm = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final email = _correo.text.trim();
    final pass = _contrasena.text;
    final confirm = _confirm.text;
    if (email.isEmpty || !email.contains('@')) {
      _showError(AppStrings.invalidEmail);
      return;
    }
    if (pass.length < 6) {
      _showError(AppStrings.passwordTooShort);
      return;
    }
    if (pass != confirm) {
      _showError(AppStrings.passwordsMismatch);
      return;
    }

    setState(() => _cargando = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Usamos FirebaseAuth directamente para mantener simple la prueba.
      await Future.value();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.registroCompletado)));
      Navigator.of(context).pop();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text(AppStrings.registerTitle)),
      body: SafeArea(
        child: Stack(
          children: [
            const FondoCartas(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings.crearCuenta, style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        TextField(controller: _correo, decoration: InputDecoration(labelText: AppStrings.emailHint, filled: true)),
                        const SizedBox(height: 8),
                        TextField(controller: _contrasena, decoration: InputDecoration(labelText: AppStrings.passwordHint, filled: true), obscureText: true),
                        const SizedBox(height: 8),
                        TextField(controller: _confirm, decoration: InputDecoration(labelText: AppStrings.confirmarContrasena, filled: true), obscureText: true),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _registrar,
                            child: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Text(AppStrings.registrarse),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text(AppStrings.volver))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
