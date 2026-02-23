import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';

class IndicadorBaza extends StatelessWidget {
  final bool ganada;

  const IndicadorBaza({super.key, this.ganada = false});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;
    final double size = esPantallaPequena
        ? 14
        : (esPantallaIntermedia ? 16 : 18);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ganada ? Colores.acento : Colors.transparent,
        border: Border.all(
          color: ganada ? Colores.acento : Colores.blanco,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
