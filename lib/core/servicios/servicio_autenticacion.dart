import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/usuario_model.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? cred;
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      cred = await _auth.signInWithPopup(provider);
    } else {
      final google = GoogleSignIn();
      final account = await google.signIn();
      if (account == null) {
        return null;
      }
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      cred = await _auth.signInWithCredential(credential);
    }

    // Guardar perfil en Firestore si no existe
    final user = cred.user;
    if (user != null) {
      await _guardarUsuarioSiNoExiste(user);
    }
    return cred;
  }

  Future<void> _guardarUsuarioSiNoExiste(User user) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        final newUser = UsuarioModel(
          uid: user.uid,
          email: user.email ?? '',
          nombreUsuario: (user.email ?? 'Usuario').split('@')[0],
          avatar: 1,
          fechaCreacion: DateTime.now(),
        );
        final map = newUser.toMap();

        map['fecha_creacion'] = FieldValue.serverTimestamp();

        await doc.set(map);
      }
    } catch (_) {}
  }

  Future<void> signOut() async => _auth.signOut();
}
