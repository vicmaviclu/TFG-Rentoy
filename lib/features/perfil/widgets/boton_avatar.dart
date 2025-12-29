import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constantes/textos.dart';

import '../../../core/constantes/colores.dart';
import '../../../core/constantes/recursos.dart';

/// Botón circular que muestra el avatar del usuario.
class BotonAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  const BotonAvatar({this.radius = 24, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Avatar por defecto si no hay usuario
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colores.blanco24,
          child: const Icon(Icons.person),
        ),
      );
    }

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);
    // Escucha cambios en el avatar del usuario
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data()!;
          final av = data['avatar'];
          final int avatarIndex = (av is int) ? av : 1;
          final assetPath = Recursos.obtenerAvatar(avatarIndex);
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                color: Colores.blanco24,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colores.blanco24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Image.asset(
                      assetPath,
                      errorBuilder: (context, error, stack) {
                        return Center(
                          child: Text(
                            (user.email ?? '?')[0].toUpperCase(),
                            style: EstilosTexto.cuerpo.copyWith(
                              color: Colores.textoPrimario,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Estado de carga o sin datos
        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colores.blanco24,
            child: const Icon(Icons.person),
          ),
        );
      },
    );
  }
}
