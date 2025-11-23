import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/servicios/servicio_autenticacion.dart';

/// Pantalla principal que se muestra después de iniciar sesión.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Cadenas.nombreApp),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              // La navegación se gestiona automáticamente por el `StreamBuilder` en `aplicacion.dart`
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${Cadenas.bienvenido}!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            if (user != null)
              Text(
                user.email ?? user.uid,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar la lógica para iniciar una partida.
              },
              child: Text(Cadenas.iniciarPartida),
            ),
          ],
        ),
      ),
    );
  }
}
