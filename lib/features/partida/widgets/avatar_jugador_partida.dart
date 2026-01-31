import 'package:flutter/material.dart';
import '../../../core/constantes/recursos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

class AvatarJugadorPartida extends StatelessWidget {
  final String nombre;
  final int avatar;
  final List<dynamic>? mano;
  final bool esMiJugador;

  const AvatarJugadorPartida({
    super.key,
    required this.nombre,
    required this.avatar,
    this.mano,
    this.esMiJugador = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cartas encima del nombre (si existen)
        // Cartas encima del nombre (si existen y soy yo)
        if (esMiJugador && mano != null && mano!.isNotEmpty)
          SizedBox(
            height: 150, // Altura suficiente para cartas grandes
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: mano!.map((cartaMap) {
                // Reconstruir la ruta de la imagen
                if (cartaMap is! Map) return const SizedBox.shrink();

                final numero = cartaMap['numero']?.toString() ?? '0';
                final palo = cartaMap['palo']?.toString() ?? '';
                if (numero == '0' || palo.isEmpty)
                  return const SizedBox.shrink();

                final prefijo = palo[0];
                final path =
                    'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Image.asset(
                    path,
                    width: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        size: 30,
                        color: Colors.red,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),

        if (mano != null && mano!.isNotEmpty) const SizedBox(height: 4),

        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: esMiJugador
                ? Colores.secundario.withOpacity(0.2)
                : Colores.blanco12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: esMiJugador ? Colores.secundario : Colors.transparent,
              width: 2,
            ),
            image: DecorationImage(
              image: AssetImage(Recursos.obtenerAvatar(avatar)),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: EstilosTexto.caption.copyWith(
            color: Colores.blanco,
            fontWeight: esMiJugador ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
