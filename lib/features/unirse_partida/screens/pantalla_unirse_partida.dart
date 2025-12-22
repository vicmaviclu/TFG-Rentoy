import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/widgets/plantilla_pantalla_principal.dart';

class PantallaUnirsePartida extends StatelessWidget {
  const PantallaUnirsePartida({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantillaPantallaPrincipal(
      mostrarVolver: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TextoPartida.tituloUnirsePartida,
            style: EstilosTexto.tituloMedio.copyWith(
              color: Colores.blanco,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          // TODO: Añadir entrada de PIN y botón de unirse
          const SizedBox(height: 20),
          Text(
            TextoPartida.introducePin,
            style: EstilosTexto.subtitulo.copyWith(color: Colores.blanco70),
          ),
        ],
      ),
    );
  }
}
