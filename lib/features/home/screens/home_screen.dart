import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../app/rutas.dart';
// import '../../../core/servicios/servicio_autenticacion.dart'; // no usado aquí
import '../../auth/widgets/tarjeta_auth.dart';
import '../../perfil/screens/pantalla_perfil.dart';
import '../../perfil/widgets/avatar_button.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../crear_partida/widgets/crear_partida_overlay.dart';
// no overlay import - restore original navigation behaviour
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
      topRight: AvatarButton(
        radius: 28,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PantallaPerfil())),
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
                  Text(
                    user.email ?? user.uid,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200, // Ancho fijo para botones más grandes
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const CrearPartidaOverlay(),
                          );
                        },
                        child: Text(Cadenas.btnCrearPartida),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacio entre botones
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, RutasApp.unirsePartida);
                        },
                        child: Text(Cadenas.btnUnirsePartida),
                      ),
                    ),
                  ],
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
