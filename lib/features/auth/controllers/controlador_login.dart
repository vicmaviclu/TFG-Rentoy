import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/servicios/servicio_autenticacion.dart';
import '../../../core/constantes/cadenas.dart';

/// Controlador para la pantalla de inicio de sesión.
///
/// Contiene los `TextEditingController` para los campos, el estado de carga
/// y los métodos que delegan en `AuthService`/Firebase para autenticación.
class ControladorLogin extends ChangeNotifier {
  final TextEditingController controladorCorreo = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();

  bool _cargando = false;
  bool get cargando => _cargando;

  @override
  void dispose() {
    controladorCorreo.dispose();
    controladorContrasena.dispose();
    super.dispose();
  }

  void _setCargando(bool v) {
    _cargando = v;
    notifyListeners();
  }

  /// Intenta iniciar sesión con Google. Devuelve `null` si tuvo éxito,
  /// o un mensaje de error en caso contrario.
  Future<String?> iniciarSesionConGoogle() async {
    _setCargando(true);
    try {
      await AuthService.instance.signInWithGoogle();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setCargando(false);
    }
  }

  /// Intenta iniciar sesión con email/contraseña. Devuelve `null` si ok,
  /// o un texto con el error.
  Future<String?> iniciarSesionConEmail() async {
    _setCargando(true);
    try {
      final email = controladorCorreo.text.trim();
      final pass = controladorContrasena.text;
      if (email.isEmpty || !email.contains('@')) return AppStrings.invalidEmail;
      if (pass.length < 6) return AppStrings.passwordTooShort;
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _setCargando(false);
    }
  }

  /// Intenta registrar un nuevo usuario con email/contraseña.
  Future<String?> registrarConEmail() async {
    _setCargando(true);
    try {
      final email = controladorCorreo.text.trim();
      final pass = controladorContrasena.text;
      if (email.isEmpty || !email.contains('@')) return AppStrings.invalidEmail;
      if (pass.length < 6) return AppStrings.passwordTooShort;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _setCargando(false);
    }
  }
}
