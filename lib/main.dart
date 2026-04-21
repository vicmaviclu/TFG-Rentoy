import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/aplicacion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Si ya está inicializada, nos aseguramos de que sea accesible
      Firebase.app();
    }
  } catch (e) {
    debugPrint('Firebase initialization handled: $e');
  }
  runApp(const AplicacionWidget());
}
