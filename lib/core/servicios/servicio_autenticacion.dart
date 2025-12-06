import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      final cred = await _auth.signInWithPopup(provider);
      // Guardar perfil en Firestore si no existe
      try {
        final user = cred.user;
        if (user != null) {
          final doc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
          final snapshot = await doc.get();
          if (!snapshot.exists) {
            await doc.set({
              'email': user.email ?? '',
              'nombre_usuario': user.email ?? '',
              'avatar': 1,
              'fecha_creacion': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (_) {}
      return cred;
    } else {
      final google = GoogleSignIn();
      final account = await google.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      // Guardar perfil en Firestore si no existe
      try {
        final user = cred.user;
        if (user != null) {
          final doc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
          final snapshot = await doc.get();
          if (!snapshot.exists) {
            await doc.set({
              'email': user.email ?? '',
              'nombre_usuario': user.email ?? '',
              'avatar': 1,
              'fecha_creacion': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (_) {}
      return cred;
    }
  }

  Future<void> signOut() async => _auth.signOut();
}
