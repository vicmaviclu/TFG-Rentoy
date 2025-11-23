import 'package:flutter/material.dart';

import '../../../core/constantes/colores.dart';
import '../../../core/constantes/tamanos.dart';

/// Componente reutilizable que envuelve el contenido de autenticación
/// con la decoración, sombra y tamaño de tarjeta usados en login/registro.
class TarjetaAuth extends StatelessWidget {
  const TarjetaAuth({super.key, required this.child, required this.size});

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height * 0.8),
      child: SizedBox(
        width: size.width < 600 ? size.width * 0.92 : 700,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tamanos.cardRadius)),
          child: Container(
            decoration: BoxDecoration(
              color: Colores.fondo,
              borderRadius: BorderRadius.circular(Tamanos.cardRadius),
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tamanos.cardPadding, vertical: 10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
