import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tema.dart';
import '../features/auth/screens/pantalla_login.dart';
import 'splash.dart';
import 'rutas.dart';
import '../core/constantes/cadenas.dart';

class AplicacionWidget extends StatelessWidget {
  const AplicacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: TemaApp.temaClaro,
      // `home` gestiona el estado de autenticación; las rutas nombradas
      // se usan para navegación (por ejemplo, registro).
      home: const SwitchEstadoAuth(),
      routes: RutasApp.todas,
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
          if (user == null) return const LoginScreen();
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.appName)),
            body: Center(child: Text('${AppStrings.bienvenido} ${user.email ?? user.uid}')),
            floatingActionButton: FloatingActionButton(
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              child: const Icon(Icons.logout),
            ),
          );
        }
        return const Scaffold(body: Center(child: SplashScreen()));
      },
    );
  }
}
