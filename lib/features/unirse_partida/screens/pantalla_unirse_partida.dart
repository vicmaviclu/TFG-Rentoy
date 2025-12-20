import 'package:flutter/material.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';

class PantallaUnirsePartida extends StatelessWidget {
  const PantallaUnirsePartida({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PaginaFondo(
      showTitle: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colores.blanco),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(
            height: size.height * 0.6,
            child: Center(
              child: Text(
                TextoPartida.tituloUnirsePartida,
                style: EstilosTexto.tituloMedio.copyWith(color: Colores.blanco),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
