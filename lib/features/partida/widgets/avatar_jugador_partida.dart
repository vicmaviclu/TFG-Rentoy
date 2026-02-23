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

  /// Indica si es el turno del jugador (para bordes del avatar)
  final bool esSuTurno;

  /// Indica si es el turno del jugador Y es el usuario actual (para las cartas)
  final bool esMiTurnoPropio;

  /// Altura deseada para las cartas
  final double alturaCarta;

  /// Si las cartas deben mostrarse ocultas
  final bool ocultarCartas;

  const AvatarJugadorPartida({
    super.key,
    required this.jugador,
    this.esMiJugador = false,
    this.cartaSeleccionadaIndex,
    this.onSeleccionar,
    this.esSuTurno = false,
    this.esMiTurnoPropio = false,
    this.alturaCarta = 120.0,
    this.ocultarCartas = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;

    // --- AVATAR DEL JUGADOR ---
    final double tamanoAvatar = (alturaCarta * 0.45).clamp(
      esPantallaPequena ? 30.0 : (esPantallaIntermedia ? 35.0 : 40.0),
      esPantallaPequena ? 65.0 : (esPantallaIntermedia ? 80.0 : 90.0),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cartas encima del nombre (si existen y soy yo)
        if (esMiJugador && jugador.mano != null && jugador.mano!.isNotEmpty)
          ManoInteractiva(
            mano: jugador.mano!,
            cartaSeleccionadaIndex: cartaSeleccionadaIndex,
            onSeleccionar: onSeleccionar ?? (i) {},
            esTuTurno: esMiTurnoPropio,
            alturaCarta: alturaCarta,
            ocultas: ocultarCartas,
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
            border: esSuTurno
                ? Border.all(color: Colores.acento, width: 3)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              Recursos.obtenerAvatar(jugador.avatar),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, color: Colores.blanco54);
              },
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
