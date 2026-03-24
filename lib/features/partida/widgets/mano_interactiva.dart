import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';

/// Widget que muestra la mano de cartas del jugador con interacción.
class ManoInteractiva extends StatelessWidget {
  /// Lista de cartas en mano
  final List<dynamic> mano;

  /// Índice de la carta seleccionada (desde el padre)
  final int? cartaSeleccionadaIndex;

  /// Callback cuando se selecciona una carta
  final Function(int index) onSeleccionar;

  /// Indica si es el turno del jugador
  final bool esTuTurno;

  /// Altura deseada para las cartas
  final double alturaCarta;

  const ManoInteractiva({
    super.key,
    required this.mano,
    required this.cartaSeleccionadaIndex,
    required this.onSeleccionar,
    this.esTuTurno = false,
    this.alturaCarta = 120.0,
    this.ocultas = false,
  });

  /// Si las cartas deben mostrarse ocultas (reverso)
  final bool ocultas;

  @override
  Widget build(BuildContext context) {
    // --- CONSTANTES DE DIMENSIONES ---
    final double kAlturaMano = alturaCarta + 10.0;
    final double kAlturaCarta = alturaCarta;
    final double kAnchoCarta = kAlturaCarta * (2 / 3);

    // --- CONTENEDOR DE LA MANO ---
    return SizedBox(
      height: kAlturaMano,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // --- LISTA HORIZONTAL DE CARTAS ---
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

                if (numero == '0' || palo.isEmpty) {
                  return const SizedBox.shrink();
                }

                final prefijo = palo[0];
                final path = ocultas
                    ? 'assets/images/cartas/reverso.png'
                    : 'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

                // Verificar si esta carta está seleccionada
                final esSeleccionada = cartaSeleccionadaIndex == index;

                // --- CARTA INDIVIDUAL ---
                return GestureDetector(
                  onTap: () {
                    // Verificar si es el turno del jugador
                    if (!esTuTurno) return;

                    // Notificar selección al widget padre
                    onSeleccionar(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      left: 4,
                      right: 4,
                      bottom: esSeleccionada ? 5 : 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: esSeleccionada ? Colores.acento : Colors.black,
                        width: esSeleccionada ? 3 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: esSeleccionada
                          ? [
                              BoxShadow(
                                color: Colores.acento.withValues(alpha: 0.5),
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
