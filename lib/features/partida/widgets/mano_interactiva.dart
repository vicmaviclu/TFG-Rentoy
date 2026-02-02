import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';

class ManoInteractiva extends StatelessWidget {
  final List<dynamic> mano;
  // Index of the selected card, passed from parent
  final int? cartaSeleccionadaIndex;
  // Callback when a card is selected
  final Function(int index) onSeleccionar;
  final bool esTuTurno;

  const ManoInteractiva({
    super.key,
    required this.mano,
    required this.cartaSeleccionadaIndex,
    required this.onSeleccionar,
    this.esTuTurno = false,
  });

  @override
  Widget build(BuildContext context) {
    // Altura suficiente para las cartas (120)
    const double kAlturaMano = 120;

    // Configuración de cartas
    const double kAlturaCarta = 90;
    const double kAnchoCarta = 65;

    return SizedBox(
      height: kAlturaMano,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Lista de Cartas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(mano.length, (index) {
                final cartaMap = mano[index];
                if (cartaMap is! Map) return const SizedBox.shrink();

                final usada = cartaMap['usada'] == true;
                if (usada) return const SizedBox.shrink();

                final numero = cartaMap['numero']?.toString() ?? '0';
                final palo = cartaMap['palo']?.toString() ?? '';

                if (numero == '0' || palo.isEmpty)
                  return const SizedBox.shrink();

                final prefijo = palo[0];
                final path =
                    'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

                // Determinar si esta carta es la seleccionada usando la prop
                final esSeleccionada = cartaSeleccionadaIndex == index;

                return GestureDetector(
                  onTap: () {
                    // Si no es mi turno, no hago nada
                    if (!esTuTurno) return;

                    // Notificar al padre la selección
                    onSeleccionar(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      left: 4,
                      right: 4,
                      bottom: esSeleccionada ? 20 : 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: esSeleccionada ? Colores.acento : Colors.black,
                        width: esSeleccionada ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: esSeleccionada
                          ? [
                              BoxShadow(
                                color: Colores.acento.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        path,
                        width: kAnchoCarta,
                        height: kAlturaCarta,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => Container(
                          width: kAnchoCarta,
                          height: kAlturaCarta,
                          color: Colors.white,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
