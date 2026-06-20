import 'package:flutter/material.dart';
import 'package:rentoy/core/constantes/colores.dart';
import 'fondo_cartas.dart';
import '../constantes/cadenas.dart';
import '../constantes/textos.dart';
import '../constantes/recursos.dart';

/// Componente que encapsula el fondo con las "cartas" y el logo grande
/// semitransparente, además de proporcionar el layout superior común.
class PaginaFondo extends StatelessWidget {
  final Widget child;
  final bool mostrarTitulo;
  final bool conScroll;
  final Widget? widgetSuperiorDerecha;

  const PaginaFondo({
    super.key,
    required this.child,
    this.mostrarTitulo = true,
    this.conScroll = true,
    this.widgetSuperiorDerecha,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content;
    if (mostrarTitulo) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            TextoComun.nombreApp,
            style: EstilosTexto.titulo.copyWith(
              color: Colores.blanco,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          child,
        ],
      );
    } else {
      content = child;
    }

    if (conScroll) {
      content = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: content,
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: content),
      );
    }

    return Scaffold(
      backgroundColor: Colores.transparente,
      body: SafeArea(
        child: Stack(
          children: [
            const FondoCartas(),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(
                    child: Image.asset(
                      Recursos.logo,
                      width: size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Center(child: content),
            if (widgetSuperiorDerecha != null)
              Positioned(top: 8, right: 8, child: widgetSuperiorDerecha!),
          ],
        ),
      ),
    );
  }
}
