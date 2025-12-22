import 'package:flutter/material.dart';
import 'package:rentoy/core/constantes/colores.dart';

class ContenedorPrincipal extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const ContenedorPrincipal({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),

      constraints: const BoxConstraints(minWidth: 300),
      decoration: BoxDecoration(
        color: Colores.fondo,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1B5E20), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 8),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
