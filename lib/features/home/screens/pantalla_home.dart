import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';
import '../../../models/usuario_model.dart';
import '../widgets/menu_principal.dart';

/// Pantalla principal tras iniciar sesión.
class PantallaHome extends StatelessWidget {
  const PantallaHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PlantillaPantallaPrincipal(
      mostrarAvatar: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 45),
          // Título de bienvenida
          Text(
            TextoAuth.bienvenido,
            style: EstilosTexto.tituloGrande.copyWith(color: Colores.blanco),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (user != null) ...[
            // Información del usuario (nombre de usuario de Firestore)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String displayName = user.email ?? user.uid;
                if (snapshot.hasData && snapshot.data!.exists) {
                  try {
                    final usuarioModel = UsuarioModel.fromDocument(snapshot.data!);
                    if (usuarioModel.nombreUsuario.isNotEmpty) {
                      displayName = usuarioModel.nombreUsuario;
                    }
                  } catch (_) {}
                }
                return Text(
                  displayName,
                  style: EstilosTexto.tituloMedio.copyWith(color: Colores.blanco70),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
          // Menú principal
          const MenuPrincipal(),
        ],
      ),
    );
  }
}
