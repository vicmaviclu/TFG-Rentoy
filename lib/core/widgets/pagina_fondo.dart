import 'package:flutter/material.dart';
import 'fondo_cartas.dart';
import '../constantes/cadenas.dart';
import '../constantes/textos.dart';
import '../constantes/recursos.dart';

/// Componente que encapsula el fondo con las "cartas" y el logo grande
/// semitransparente, además de proporcionar el layout superior común
/// utilizado en varias páginas (padding, scroll, título del juego).
class PaginaFondo extends StatelessWidget {
  const PaginaFondo({super.key, required this.child, this.showTitle = true});

  final Widget child;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            const FondoCartas(),
            Positioned.fill(
                child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(child: Image.asset(Recursos.logo, width: size.width * 0.8, fit: BoxFit.contain)),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showTitle) ...[
                      Text(
                              Cadenas.nombreApp,
                          style: EstilosTexto.titulo.copyWith(color: Colors.white, fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
