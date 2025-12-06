import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
// import '../../../core/servicios/servicio_autenticacion.dart'; // no usado aquí
import '../../auth/widgets/tarjeta_auth.dart';
import '../../perfil/screens/pantalla_perfil.dart';
import '../../../core/widgets/pagina_fondo.dart';
// import '../../../core/constantes/tamanos.dart';

/// Pantalla principal que se muestra después de iniciar sesión.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;

    return PaginaFondo(
      showTitle: true,
      topRight: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaPerfil()));
        },
        child: CircleAvatar(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.12),
          child: Text((user?.email ?? '').isNotEmpty ? (user!.email![0].toUpperCase()) : '?'),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TarjetaAuth(
            size: size,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Cadenas.bienvenido,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (user != null) ...[
                  Text(user.email ?? user.uid, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar la lógica para iniciar una partida.
                  },
                  child: Text(Cadenas.iniciarPartida),
                ),
              ],
            ),
          ),
        ],
      ),
      // AppBar style: put profile button in the scaffold's appbar via nested Scaffold
      // Use a small top bar to match other screens
    );
  }
}
