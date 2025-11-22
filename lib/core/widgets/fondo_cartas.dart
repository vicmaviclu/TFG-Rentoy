import 'package:flutter/material.dart';

/// Fondo reutilizable con estética tipo "juego de cartas".
///
/// Implementado con un degradado y varias cartas estilizadas dibujadas
/// por Widgets para no depender de un asset externo. Si quieres usar una
/// imagen real más adelante, basta con cambiar la decoración.
class FondoCartas extends StatelessWidget {
  final Widget? child;
  const FondoCartas({this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Degradado base (tonos verdes tipo MUS Online)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E8B57), Color(0xFF3FAF8E)],
            ),
          ),
        ),

        // Figuras tipo cartas - posiciones fijas para decoración
        Positioned(
          left: -40,
          top: 40,
          child: Transform.rotate(
            angle: -0.2,
            child: _CartaDecorada(width: 180, height: 260, opacity: 0.08),
          ),
        ),
        Positioned(
          right: -60,
          top: 120,
          child: Transform.rotate(
            angle: 0.15,
            child: _CartaDecorada(width: 220, height: 300, opacity: 0.07),
          ),
        ),
        Positioned(
          left: 20,
          bottom: -40,
          child: Transform.rotate(
            angle: 0.12,
            child: _CartaDecorada(width: 180, height: 260, opacity: 0.06),
          ),
        ),

        // Overlay levemente texturizado (sólo color semitransparente)
        Container(color: const Color.fromRGBO(0, 0, 0, 0.12)),

        // Child encima de todo
        if (child != null) child!,
      ],
    );
  }
}

class _CartaDecorada extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  const _CartaDecorada({required this.width, required this.height, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, opacity),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25 * opacity), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 40, decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, opacity * 1.6), borderRadius: BorderRadius.circular(6))),
            const Spacer(),
            Row(
              children: [
                Container(width: 22, height: 30, decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, opacity * 1.3), borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 6),
                Container(width: 22, height: 30, decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, opacity * 1.1), borderRadius: BorderRadius.circular(4))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
