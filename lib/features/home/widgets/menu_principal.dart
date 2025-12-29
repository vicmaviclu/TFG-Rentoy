import 'package:flutter/material.dart';

import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../crear_partida/widgets/crear_partida_overlay.dart';
import '../../unirse_partida/widgets/unirse_partida_overlay.dart';

/// Botones principales del menú Home.
class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón crear partida
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.secundario,
              foregroundColor: Colores.textoPrimario,
              textStyle: EstilosTexto.boton,
              elevation: 4,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CrearPartidaOverlay(),
              );
            },
            child: Text(TextoPartida.btnCrearPartida),
          ),
        ),
        const SizedBox(height: 16),
        // Botón unirse a partida
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.blanco,
              foregroundColor: Colores.textoPrimario,
              textStyle: EstilosTexto.boton,
              elevation: 4,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const UnirsePartidaOverlay(),
              );
            },
            child: Text(TextoPartida.btnUnirsePartida),
          ),
        ),
      ],
    );
  }
}
