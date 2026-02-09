import 'package:flutter/material.dart';
import '../../../core/constantes/recursos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../models/usuario_model.dart';
import 'mano_interactiva.dart';

/// Widget que muestra el avatar y nombre del jugador con sus cartas.
class AvatarJugadorPartida extends StatelessWidget {
  /// Modelo de datos del jugador
  final UsuarioModel jugador;

  /// Indica si este jugador es el usuario actual
  final bool esMiJugador;

  /// Índice de la carta seleccionada (estado del padre)
  final int? cartaSeleccionadaIndex;

  /// Callback cuando se selecciona una carta
  final Function(int)? onSeleccionar;

  /// Indica si es el turno del jugador
  final bool esMiTurno;

  /// Altura deseada para las cartas
  final double alturaCarta;

  const AvatarJugadorPartida({
    super.key,
    required this.jugador,
    this.esMiJugador = false,
    this.cartaSeleccionadaIndex,
    this.onSeleccionar,
    this.esMiTurno = false,
    this.alturaCarta = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    // --- AVATAR DEL JUGADOR ---
    final double tamanoAvatar = (alturaCarta * 0.45).clamp(40.0, 65.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cartas encima del nombre (si existen y soy yo)
        if (esMiJugador && jugador.mano != null && jugador.mano!.isNotEmpty)
          ManoInteractiva(
            mano: jugador.mano!,
            cartaSeleccionadaIndex: cartaSeleccionadaIndex,
            onSeleccionar: onSeleccionar ?? (i) {},
            esTuTurno: esMiTurno,
            alturaCarta: alturaCarta,
          ),

        // Espacio entre cartas y avatar
        if (jugador.mano != null && jugador.mano!.isNotEmpty)
          const SizedBox(height: 4),

        // --- AVATAR DEL JUGADOR ---
        Container(
          width: tamanoAvatar,
          height: tamanoAvatar,
          decoration: BoxDecoration(
            color: esMiJugador
                ? Colores.secundario.withValues(alpha: 0.2)
                : Colores.blanco12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: esMiJugador ? Colores.secundario : Colors.transparent,
              width: 2,
            ),
            image: DecorationImage(
              image: AssetImage(Recursos.obtenerAvatar(jugador.avatar)),
              fit: BoxFit.contain,
            ),
          ),
        ),
        // --- NOMBRE DEL JUGADOR ---
        const SizedBox(height: 4),
        Text(
          jugador.nombreUsuario,
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
