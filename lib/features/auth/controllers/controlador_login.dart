import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/servicios/servicio_autenticacion.dart';
import '../../../core/constantes/errores.dart';

// Typedef para las funciones de autenticación por email/contraseña.
// Hace el código más legible y facilita el uso en parámetros y mocks.
typedef AuthEmailFn =
    Future<UserCredential> Function(String email, String password);

/// Controlador para la pantalla de inicio de sesión.
///
/// Contiene los `TextEditingController` para los campos, el estado de carga
/// y los métodos que delegan en `AuthService`/Firebase para autenticación.
class ControladorLogin extends ChangeNotifier {
  final TextEditingController controladorCorreo = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();
  final TextEditingController controladorUsuario = TextEditingController();

  bool _cargando = false;
  bool get cargando => _cargando;

  // Marca para evitar notificar listeners después de `dispose()`.
  bool _disposed = false;

  // Funciones inyectables para facilitar testing. Por defecto usan FirebaseAuth.
  final AuthEmailFn _signInWithEmail;
  final AuthEmailFn _createUserWithEmail;

  ControladorLogin({
    AuthEmailFn? signInWithEmail,
    AuthEmailFn? createUserWithEmail,
  }) : _signInWithEmail =
           signInWithEmail ??
           ((email, password) => FirebaseAuth.instance
               .signInWithEmailAndPassword(email: email, password: password)),
       _createUserWithEmail =
           createUserWithEmail ??
           ((email, password) =>
               FirebaseAuth.instance.createUserWithEmailAndPassword(
                 email: email,
                 password: password,
               ));

  @override
  void dispose() {
    controladorCorreo.dispose();
    controladorContrasena.dispose();
    controladorUsuario.dispose();
    _disposed = true;
    super.dispose();
  }

  void _setCargando(bool v) {
    _cargando = v;
    if (!_disposed) notifyListeners();
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
      if (email.isEmpty || !email.contains('@'))
        return ErroresValidacion.emailInvalido;
      await _signInWithEmail(email, pass);
      return null;
    } on FirebaseAuthException catch (e) {
      // Mapear códigos de Firebase a mensajes amigables cuando sea posible
      return mensajeErrorFirebaseAuth(e.code);
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
      final username = controladorUsuario.text.trim();
      final pass = controladorContrasena.text;
      if (email.isEmpty || !email.contains('@'))
        return ErroresValidacion.emailInvalido;
      if (pass.length < 6) return ErroresValidacion.contrasenaCorta;
      if (username.isEmpty) return 'Introduce un nombre de usuario';

      // Comprobar si el nombre de usuario ya existe en la colección 'usuarios'
      final existente = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nombre_usuario', isEqualTo: username)
          .limit(1)
          .get();
      if (existente.docs.isNotEmpty) {
        return 'El nombre de usuario ya está en uso';
      }

      // Crear el usuario en Firebase Auth
      await _createUserWithEmail(email, pass);

      // Guardar datos adicionales en Firestore (sin contraseña)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'email': email,
          'nombre_usuario': username,
          'avatar': 1,
          'fecha_creacion': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return mensajeErrorFirebaseAuth(e.code);
    } catch (e) {
      return e.toString();
    } finally {
      _setCargando(false);
    }
  }
}
