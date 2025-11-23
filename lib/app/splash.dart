import 'package:flutter/material.dart';
import '../core/constantes/recursos.dart';

/// Pantalla de splash que muestra el logo de Rentoy mientras se carga.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo del proyecto (asset incluido en pubspec.yaml)
          Image.asset(Recursos.logo, width: 160, height: 160, fit: BoxFit.cover),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
