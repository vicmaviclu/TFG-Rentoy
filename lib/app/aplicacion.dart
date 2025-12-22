import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tema.dart';
import '../features/auth/screens/pantalla_login.dart';
import '../features/home/screens/pantalla_home.dart';
import 'splash.dart';
import 'rutas.dart';
import '../core/constantes/cadenas.dart';

class AplicacionWidget extends StatelessWidget {
  const AplicacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TextoComun.nombreApp,
      theme: TemaApp.temaClaro,
      home: const SwitchEstadoAuth(),
      routes: RutasApp.rutasApp,
    );
  }
}

class SwitchEstadoAuth extends StatelessWidget {
  const SwitchEstadoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) return const PantallaLogin();
          return const PantallaHome();
        }
        return const Scaffold(body: Center(child: SplashScreen()));
      },
    );
  }
}
