import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

class AccionesSala extends StatelessWidget {
  final bool salaLlena;
  final VoidCallback? alInvitar;
  final VoidCallback? alEmpezar;

  const AccionesSala({
    super.key,
    required this.salaLlena,
    this.alInvitar,
    this.alEmpezar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(
                TextoPartida.invitarJugadores,
                style: EstilosTexto.boton.copyWith(color: Colores.blanco),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.blanco24,
                foregroundColor: Colores.blanco,
              ),
              onPressed: alInvitar,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: salaLlena
                    ? Colores.secundario
                    : Colores.blanco12,
                foregroundColor: salaLlena
                    ? Colores.textoPrimario
                    : Colores.blanco70,
              ),
              onPressed: salaLlena ? alEmpezar : null,
              child: Text(
                TextoPartida.empezarPartida,
                style: EstilosTexto.cuerpoNegrita.copyWith(
                  color: salaLlena ? Colores.textoPrimario : Colores.blanco70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
