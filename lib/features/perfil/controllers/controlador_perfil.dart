import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/usuario_model.dart';

import '../../../core/constantes/errores.dart';

/// Controlador de perfil: gestiona los `TextEditingController`, carga y guarda
/// los datos de perfil en Firestore y actualiza FirebaseAuth cuando procede.
class ControladorPerfil extends ChangeNotifier {
  final TextEditingController controladorNombreUsuario =
      TextEditingController();
  final TextEditingController controladorCorreo = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();

  final FirebaseFirestore? _firestore;
  final dynamic _authProvider;
  final dynamic Function() _userProvider;

  ControladorPerfil({
    FirebaseFirestore? firestore,
    dynamic Function()? userProvider,
    dynamic Function()? authProvider,
  }) : _firestore = firestore,
       _userProvider =
           userProvider ?? (() => FirebaseAuth.instance.currentUser),
       _authProvider = authProvider ?? (() => FirebaseAuth.instance);

  int _avatarSeleccionado = 1;
  int get avatarSeleccionado => _avatarSeleccionado;
  set avatarSeleccionado(int value) {
    final v = value.clamp(1, 9).toInt();
    if (v == _avatarSeleccionado) {
      return;
    }
    _avatarSeleccionado = v;
    notifyListeners();
  }

  bool cargando = false;

  dynamic get usuario => _userProvider();

  Future<void> cargarPerfil() async {
    final u = usuario;
    if (u == null) {
      return;
    }
    controladorCorreo.text = u.email ?? '';
    final fs = _firestore ?? FirebaseFirestore.instance;
    final doc = await fs.collection('usuarios').doc(u.uid).get();
    if (doc.exists) {
      // Usamos el modelo para parsear los datos
      final usuarioModel = UsuarioModel.fromDocument(doc);
      controladorNombreUsuario.text = usuarioModel.nombreUsuario;
      avatarSeleccionado = usuarioModel.avatar;
    }
    notifyListeners();
  }

  Future<String?> guardarPerfil() async {
    final u = usuario;
    if (u == null) {
      return ErroresPerfil.noAutenticado;
    }
    cargando = true;
    notifyListeners();
    try {
      final newUsername = controladorNombreUsuario.text.trim();
      if (newUsername.isEmpty) {
        return ErroresPerfil.nombreUsuarioVacio;
      }

      final fs = _firestore ?? FirebaseFirestore.instance;
      // Comprobar unicidad (simple)
      final q = await fs
          .collection('usuarios')
          .where('nombre_usuario', isEqualTo: newUsername)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final existingId = q.docs.first.id;
        if (existingId != u.uid) {
          return ErroresPerfil.nombreUsuarioEnUso;
        }
      }

      // Creamos instancia del modelo para guardar
      final nuevoModelo = UsuarioModel(
        uid: u.uid,
        email: u.email ?? '',
        nombreUsuario: newUsername,
        avatar: avatarSeleccionado,
        // La fecha de creación no la modificamos si ya existe,
      );

      final dataToSave = nuevoModelo.toMap();
      // Aseguramos fecha de actualización/creación si fuese necesario
      dataToSave['fecha_creacion'] = FieldValue.serverTimestamp();

      await fs
          .collection('usuarios')
          .doc(u.uid)
          .set(dataToSave, SetOptions(merge: true));

      // Actualizar contraseña en Auth si se proporcionó
      final newPass = controladorContrasena.text;
      if (newPass.isNotEmpty) {
        try {
          await (u as dynamic).updatePassword(newPass);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            return ErroresPerfil.requiereReautenticacion;
          }
          return e.message ?? e.code;
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return ErroresPerfil.requiereReautenticacion;
      }
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

  Future<void> signOut() async {
    final auth = _authProvider == null
        ? FirebaseAuth.instance
        : _authProvider();
    await (auth as dynamic).signOut();
  }
}
