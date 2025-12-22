import 'package:flutter/material.dart';
import '../../../../app/rutas.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../crear_partida/widgets/crear_partida_overlay.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
              Navigator.pushNamed(context, RutasApp.unirsePartida);
            },
            child: Text(TextoPartida.btnUnirsePartida),
          ),
        ),
      ],
    );
  }
}
