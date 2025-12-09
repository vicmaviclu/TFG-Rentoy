import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';

/// Widget que muestra el avatar del usuario en un CircleAvatar y reacciona
/// a cambios en Firestore en tiempo real. Si no hay avatar en la base de datos
/// muestra una letra por defecto.
class AvatarButton extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  const AvatarButton({this.radius = 24, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white24,
          child: const Icon(Icons.person),
        ),
      );
    }

    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data()!;
          final av = data['avatar'];
          final int avatarIndex = (av is int) ? av : 1;
          final assetPath = 'assets/images/avatares/avatar $avatarIndex.png';
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
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
                        return Center(child: Text((user.email ?? '?')[0].toUpperCase(), style: EstilosTexto.cuerpo.copyWith(color: Colores.textoPrimario)));
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // loading / no data
        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white24,
            child: const Icon(Icons.person),
          ),
        );
      },
    );
  }
}
