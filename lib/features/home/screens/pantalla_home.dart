import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../app/rutas.dart';
import '../../auth/widgets/tarjeta_auth.dart';
import '../../perfil/widgets/boton_avatar.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../widgets/menu_principal.dart';

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
        onTap: () => Navigator.of(context).pushNamed(RutasApp.perfil),
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
                  TextoAuth.bienvenido,
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
                const MenuPrincipal(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
