import 'package:flutter/material.dart';
import '../../../core/constantes/recursos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

class AvatarJugadorPartida extends StatelessWidget {
  final String nombre;
  final int avatar;
  final bool esMiJugador;

  const AvatarJugadorPartida({
    super.key,
    required this.nombre,
    required this.avatar,
    this.esMiJugador = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
