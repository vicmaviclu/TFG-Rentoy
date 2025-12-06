import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constantes/errores.dart';

/// Controlador de perfil: gestiona los `TextEditingController`, carga y guarda
/// los datos de perfil en Firestore y actualiza FirebaseAuth cuando procede.
class ControladorPerfil extends ChangeNotifier {
  final TextEditingController controladorNombreUsuario = TextEditingController();
  final TextEditingController controladorCorreo = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();

  int avatarSeleccionado = 1;
  bool cargando = false;

  User? get usuario => FirebaseAuth.instance.currentUser;

  Future<void> cargarPerfil() async {
    final u = usuario;
    if (u == null) return;
    controladorCorreo.text = u.email ?? '';
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(u.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      controladorNombreUsuario.text = (data['nombre_usuario'] as String?) ?? '';
      final av = data['avatar'];
      if (av is int) avatarSeleccionado = av;
    }
    notifyListeners();
  }

  Future<String?> guardarPerfil() async {
    final u = usuario;
    if (u == null) return 'No autenticado';
    cargando = true;
    notifyListeners();
    try {
      final newUsername = controladorNombreUsuario.text.trim();
      if (newUsername.isEmpty) return 'Introduce un nombre de usuario';

      // Comprobar unicidad (simple)
      final q = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nombre_usuario', isEqualTo: newUsername)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final existingId = q.docs.first.id;
        if (existingId != u.uid) return 'El nombre de usuario ya está en uso';
      }

      // Guardamos perfil en Firestore. No permitimos cambiar el email desde aquí
      // (el email en Auth es la fuente de la verdad para el correo).
      await FirebaseFirestore.instance.collection('usuarios').doc(u.uid).set({
        'nombre_usuario': newUsername,
        'avatar': avatarSeleccionado,
        'email': u.email ?? '',
        'fecha_creacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Actualizar contraseña en Auth si se proporcionó
      final newPass = controladorContrasena.text;
      if (newPass.isNotEmpty) {
        try {
          await (u as dynamic).updatePassword(newPass);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') return ErroresPerfil.requiereReautenticacion;
          return e.message ?? e.code;
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') return ErroresPerfil.requiereReautenticacion;
      return e.message ?? e.code;
    } on FirebaseException catch (e) {
      // Mapeo genérico
      return e.message ?? ErroresPerfil.errorFirebaseDesconocido;
    } catch (e) {
      return e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controladorNombreUsuario.dispose();
    controladorCorreo.dispose();
    controladorContrasena.dispose();
    super.dispose();
  }
}
