import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../models/usuario_model.dart';
import '../controllers/controlador_partida.dart';

/// Popup horizontal que muestra las cartas jugadas por cada jugador.
class PopupHistorial extends StatelessWidget {
  final List<UsuarioModel> jugadores;
  final String miUid;
  final ControladorPartida controlador;

  const PopupHistorial({
    super.key,
    required this.jugadores,
    required this.miUid,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupamos a los jugadores por equipos para mostrarlos más ordenados
    final equipos = controlador.organizarEquipos(jugadores, miUid);
    final miEquipo = equipos['abajo'] ?? [];
    final equipoRival = equipos['arriba'] ?? [];

    final soyEq1 = controlador.soyEquipo1(jugadores, miUid);
    final nombreMiEquipo = soyEq1 ? TextoPartida.equipo1 : TextoPartida.equipo2;
    final nombreEquipoRival = soyEq1
        ? TextoPartida.equipo2
        : TextoPartida.equipo1;

    return Dialog(
      backgroundColor: Colores.fondo.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colores.acento, width: 2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 270),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    TextoPartida.historialCartas,
                    style: TextStyle(
                      color: Colores.blanco,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colores.blanco),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colores.blanco24, height: 1),
            // Contenido Horizontal Scrollable
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBloqueEquipo(nombreMiEquipo, miEquipo),
                    const SizedBox(width: 32),
                    Container(width: 1, color: Colores.blanco24),
                    const SizedBox(width: 32),
                    _buildBloqueEquipo(nombreEquipoRival, equipoRival),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloqueEquipo(
    String nombreEquipo,
    List<UsuarioModel> equipoJugadores,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombreEquipo,
          style: const TextStyle(
            color: Colores.acento,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: equipoJugadores
              .map((jugador) => _buildJugadorHistorial(jugador))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildJugadorHistorial(UsuarioModel jugador) {
    final cartasUsadas =
        jugador.mano?.where((c) => c is Map && c['usada'] == true).toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            jugador.nombreUsuario,
            style: const TextStyle(
              color: Colores.blanco70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (cartasUsadas.isEmpty)
            const Text(
              TextoPartida.ninguna,
              style: TextStyle(color: Colores.blanco54, fontSize: 12),
            )
          else
            Row(
              children: cartasUsadas.map((cartaMap) {
                final numero = cartaMap['numero']?.toString() ?? '0';
                final palo = cartaMap['palo']?.toString() ?? '';
                if (numero == '0' || palo.isEmpty)
                  return const SizedBox.shrink();

                final prefijo = palo[0];
                final path =
                    'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.asset(
                        path,
                        width: 75,
                        height: 110,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 75,
                          height: 110,
                          color: Colors.white,
                          child: const Icon(
                            Icons.error,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
