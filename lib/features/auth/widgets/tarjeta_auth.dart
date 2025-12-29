import 'package:flutter/material.dart';

import '../../../core/constantes/colores.dart';
import '../../../core/constantes/tamanos.dart';

/// Tarjeta contenedora para formularios de autenticación.
class TarjetaAuth extends StatelessWidget {
  const TarjetaAuth({super.key, required this.child, required this.size});

  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width < 600 ? size.width * 0.92 : 700,
      // Contenedor principal con diseño de tarjeta
      child: Material(
        elevation: 8,
        color: Colores.transparente,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tamanos.cardRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colores.fondo,
            borderRadius: BorderRadius.circular(Tamanos.cardRadius),
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.12),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Tamanos.cardPadding,
              vertical: 10,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
