import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/servicios/servicio_autenticacion.dart';
import '../../../core/constantes/errores.dart';
import '../../../core/constantes/cadenas.dart';

// Typedef para las funciones de autenticación por email/contraseña.
typedef AuthEmailFn =
    Future<UserCredential> Function(String email, String password);

/// Controlador para gestión de autenticación (Login/Registro).
class ControladorLogin extends ChangeNotifier {
  final TextEditingController controladorCorreo = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();
  final TextEditingController controladorUsuario = TextEditingController();

  bool _cargando = false;
  bool get cargando => _cargando;

  // Evitar notificar listeners después de `dispose()`.
  bool _disposed = false;

  // Funciones inyectables para facilitar pruebas. Por defecto usan FirebaseAuth.
  final AuthEmailFn _iniciarSesionEmail;
  final AuthEmailFn _crearUsuarioEmail;
  final bool _ignorarFirestoreParaTest;

  ControladorLogin({
    AuthEmailFn? iniciarSesionEmail,
    AuthEmailFn? crearUsuarioEmail,
    bool ignorarFirestoreParaTest = false,
  }) : _ignorarFirestoreParaTest = ignorarFirestoreParaTest,
       _iniciarSesionEmail =
           iniciarSesionEmail ??
           ((email, password) => FirebaseAuth.instance
               .signInWithEmailAndPassword(email: email, password: password)),
       _crearUsuarioEmail =
           crearUsuarioEmail ??
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

  // Actualiza el estado de carga y notifica a la vista
  void _setCargando(bool v) {
    _cargando = v;
    if (!_disposed) notifyListeners();
  }

  /// Inicia sesión usando el proveedor de Google.
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

  /// Inicia sesión con correo y contraseña.
  Future<String?> iniciarSesionConEmail() async {
    _setCargando(true);
    try {
      final email = controladorCorreo.text.trim();
      final pass = controladorContrasena.text;
      if (email.isEmpty || !email.contains('@')) {
        return ErroresValidacion.emailInvalido;
      }
      await _iniciarSesionEmail(email, pass);
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

  /// Registra un nuevo usuario y guarda sus datos en Firestore.
  Future<String?> registrarConEmail() async {
    _setCargando(true);
    try {
      final email = controladorCorreo.text.trim();
      final username = controladorUsuario.text.trim();
      final pass = controladorContrasena.text;
      if (email.isEmpty || !email.contains('@')) {
        return ErroresValidacion.emailInvalido;
      }
      if (pass.length < 6) return ErroresValidacion.contrasenaCorta;
      if (username.isEmpty) return TextoAuth.introducirUsuario;

      // Comprobar si el nombre de usuario ya existe en la colección 'usuarios'
      if (!_ignorarFirestoreParaTest) {
        final existente = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('nombre_usuario', isEqualTo: username)
            .limit(1)
            .get();
        if (existente.docs.isNotEmpty) {
          return TextoAuth.usuarioEnUso;
        }
      }

      // Crear el usuario en Firebase Auth
      await _crearUsuarioEmail(email, pass);

      // Guardar datos adicionales en Firestore (sin contraseña)
      if (!_ignorarFirestoreParaTest) {
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
