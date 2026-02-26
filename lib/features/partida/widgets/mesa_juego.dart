import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/recursos.dart';
import 'package:firebase_database/firebase_database.dart';
import '../controllers/controlador_partida.dart';
import 'boton_mesa.dart';
import 'indicador_baza.dart';

/// Widget que representa la mesa de juego central con la carta ganadora.
class MesaJuego extends StatelessWidget {
  /// Controlador de la lógica de partida
  final ControladorPartida? controlador;

  /// ID de la sesión
  final String? idSesion;

  /// Si se muestra el botón de lanzar
  final bool mostrarBotonLanzar;

  /// Callback cuando se presiona el botón de lanzar
  final VoidCallback? onLanzar;

  final VoidCallback? onCambiar;
  final VoidCallback? onCantar;

  /// Cuántas bazas ha ganado el Equipo 1
  final int bazasEquipo1;

  /// Cuántas bazas ha ganado el Equipo 2
  final int bazasEquipo2;

  /// Si el jugador actual es del Equipo 1
  final bool soyEquipo1;

  const MesaJuego({
    super.key,
    this.controlador,
    this.idSesion,
    this.mostrarBotonLanzar = false,
    this.onLanzar,
    this.onCambiar,
    this.onCantar,
    this.alturaCarta,
    this.bazasEquipo1 = 0,
    this.bazasEquipo2 = 0,
    this.soyEquipo1 = true,
  });

  /// Altura de referencia para las cartas (misma que en la mano)
  final double? alturaCarta;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Breakpoints para ancho (Responsive Horizontal)
    final bool esPantallaPequena = screenWidth < 400;
    final bool esPantallaIntermedia = screenWidth >= 400 && screenWidth < 460;

    // Breakpoint para alto (Layout Vertical específico)
    // Se usa un layout distinto para pantallas "largas" (> 800 dp)
    final bool esPantallaAlta = screenHeight > 800;

    // Dimensiones de botones ajustadas al ancho
    final double kAlturaBoton = esPantallaPequena
        ? 28.0
        : (esPantallaIntermedia ? 32.0 : 35.0);
    final double kAnchoBoton = esPantallaPequena
        ? 90.0
        : (esPantallaIntermedia ? 100.0 : 110.0);
    final double kProtrusion = esPantallaPequena ? 14.0 : 18.0;
    const double kMargin = 10.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. La Mesa Visual (Fondo + Borde + Contenido)
        Positioned(
          top: 0,
          left: kMargin,
          right: kMargin,
          bottom: kMargin + kProtrusion,
          child: CustomPaint(
            painter: _MesaPainter(
              gapWidth: mostrarBotonLanzar
                  ? kAnchoBoton +
                        (esPantallaPequena
                            ? 5
                            : (esPantallaIntermedia ? 8 : 10))
                  : 0,
              buttonHeight: kAlturaBoton,
              buttonRadius: kAlturaBoton / 2,
              colorFondo: Colores.primario.withValues(alpha: 0.5),
              colorBorde: Colores.blanco24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double altoDisponible = constraints.maxHeight;
                // Calculamos el tamaño de la carta relativo al alto disponible
                final double cardHeight =
                    alturaCarta ?? (altoDisponible * 0.75);
                final double cardWidth = cardHeight * (2 / 3);

                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: esPantallaPequena
                        ? 8.0
                        : (esPantallaIntermedia ? 12.0 : 16.0),
                  ),
                  child: Stack(
                    children: [
                      // Título de Fondo (Marca de Agua)
                      Align(
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: 0.3,
                          child: Text(
                            TextoPartida.mesaDeJuego,
                            style: EstilosTexto.tituloMedio.copyWith(
                              color: Colores.blanco,
                              fontSize: altoDisponible * 0.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Contenido Principal
                      if (controlador != null && idSesion != null)
                        esPantallaAlta
                            // Layout específico para pantallas altas (Móviles largos)
                            ? _buildLayoutPantallaAlta(
                                context,
                                cardWidth,
                                cardHeight,
                                esPantallaPequena,
                                esPantallaIntermedia,
                                altoDisponible,
                              )
                            // Layout estándar para pantallas normales/anchas
                            : _buildLayoutEstandar(
                                context,
                                cardWidth,
                                cardHeight,
                                esPantallaPequena,
                                esPantallaIntermedia,
                                altoDisponible,
                              ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Botón Lanzar (Flotante en la parte inferior)
        if (mostrarBotonLanzar)
          Positioned(
            bottom: kMargin,
            left: 0,
            right: 0,
            height: kAlturaBoton,
            child: Center(
              child: SizedBox(
                width: kAnchoBoton,
                height: kAlturaBoton,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.acento,
                    foregroundColor: Colores.blanco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide.none,
                    ),
                    elevation: 10,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onLanzar,
                  child: Text(
                    TextoPartida.btnLanzar,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: esPantallaPequena
                          ? 11
                          : (esPantallaIntermedia ? 12 : 13),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper para espaciado horizontal
  double _xGap(bool esPequena) => esPequena ? 0 : 10.0;

  /// Construye el layout para pantallas altas (> 800dp).
  /// Estructura:
  /// - Arriba: Muestra (Izq) y Carta Ganadora (Der)
  /// - Centro/Abajo: Controles y Puntos
  Widget _buildLayoutPantallaAlta(
    BuildContext context,
    double cardWidth,
    double cardHeight,
    bool esPantallaPequena,
    bool esPantallaIntermedia,
    double altoDisponible,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Fila Superior: Muestra (Izq) - Carta Ganadora (Der)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCartaMuestra(cardWidth, cardHeight, altoDisponible),
            _buildCartaGanadora(cardWidth, cardHeight, altoDisponible),
          ],
        ),

        const Spacer(),

        // Centro: Botones y Puntos
        Padding(
          padding: EdgeInsets.only(bottom: altoDisponible * 0.05),
          child: _buildCentro(
            esPantallaPequena,
            esPantallaIntermedia,
            true, // Se asume layout vertical amplio
          ),
        ),

        const Spacer(),
      ],
    );
  }

  /// Construye el layout estándar (horizontal).
  /// Estructura:
  /// - Izquierda: Muestra
  /// - Centro: Controles y Puntos
  /// - Derecha: Carta Ganadora
  Widget _buildLayoutEstandar(
    BuildContext context,
    double cardWidth,
    double cardHeight,
    bool esPantallaPequena,
    bool esPantallaIntermedia,
    double altoDisponible,
  ) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- IZQUIERDA: MUESTRA ---
        SizedBox(
          width: _xGap(esPantallaPequena) + cardWidth,
          child: Center(
            child: _buildCartaMuestra(cardWidth, cardHeight, altoDisponible),
          ),
        ),

        // --- CENTRO: INFORMACIÓN DE RONDA ---
        Expanded(
          child: _buildCentro(
            esPantallaPequena,
            esPantallaIntermedia,
            false,
          ), // false = layout estándar
        ),

        // --- DERECHA: CARTA GANADORA ---
        SizedBox(
          width: _xGap(esPantallaPequena) + cardWidth,
          child: Center(
            child: _buildCartaGanadora(cardWidth, cardHeight, altoDisponible),
          ),
        ),
      ],
    );
  }

  /// Widget para mostrar la carta de muestra
  Widget _buildCartaMuestra(
    double cardWidth,
    double cardHeight,
    double altoDisponible,
  ) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: controlador!.streamCartaMuestra(idSesion!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(width: cardWidth, height: cardHeight);
        }
        final muestra = snapshot.data!;
        final numero = muestra['numero']?.toString() ?? '0';
        final palo = muestra['palo']?.toString() ?? '';
        final path = Recursos.obtenerCarta(palo, numero);

        if (path.isEmpty) {
          return SizedBox(width: cardWidth, height: cardHeight);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                TextoPartida.muestra,
                style: EstilosTexto.subtitulo.copyWith(
                  color: Colores.blanco,
                  fontSize: (altoDisponible * 0.035).clamp(10.0, 14.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  path,
                  width: cardWidth,
                  height: cardHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget para mostrar la carta ganadora actual
  Widget _buildCartaGanadora(
    double cardWidth,
    double cardHeight,
    double altoDisponible,
  ) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: controlador!.streamCartaGanadora(idSesion!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(width: cardWidth, height: cardHeight);
        }

        final dataGanadora = snapshot.data!;
        final carta = dataGanadora['carta'];
        final jugador = dataGanadora['jugador']?.toString() ?? '';

        if (carta is! Map) {
          return SizedBox(width: cardWidth, height: cardHeight);
        }

        final numero = carta['numero']?.toString() ?? '0';
        final palo = carta['palo']?.toString() ?? '';
        final path = Recursos.obtenerCarta(palo, numero);

        if (path.isEmpty) {
          return SizedBox(width: cardWidth, height: cardHeight);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                jugador, // Solo mostramos el nombre del jugador
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: EstilosTexto.subtitulo.copyWith(
                  color: Colores.blanco,
                  fontSize: (altoDisponible * 0.035).clamp(10.0, 14.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  path,
                  width: cardWidth,
                  height: cardHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget central con información de ronda, puntos y botones
  Widget _buildCentro(
    bool esPantallaPequena,
    bool esPantallaIntermedia,
    bool esMuyAlta,
  ) {
    return StreamBuilder<DatabaseEvent>(
      stream: controlador!.streamPartida(idSesion ?? ''),
      builder: (context, snapshot) {
        String textoRonda = "${TextoPartida.ronda} 1";
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final val = snapshot.data!.snapshot.value as Map;
          if (val['rondas'] != null && val['rondas']['actual'] != null) {
            textoRonda = "${TextoPartida.ronda} ${val['rondas']['actual']}";
          }
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Texto Ronda
            Text(
              textoRonda,
              style: EstilosTexto.subtitulo.copyWith(
                color: Colores.blanco,
                fontWeight: FontWeight.bold,
                fontSize: esPantallaPequena
                    ? 14
                    : (esPantallaIntermedia ? 15 : 16),
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Grupo Central: Botones + (Puntos/Indicadores)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Botón Cantar
                BotonMesa(
                  icon: Icons.mic,
                  label: TextoPartida.cantar,
                  onTap: onCantar ?? () {},
                ),

                SizedBox(width: esMuyAlta ? 40 : (esPantallaPequena ? 4 : 18)),

                // Columna Central: Indicadores + Puntos
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicadores Equipo Rival (Arriba)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IndicadorBaza(
                            ganada: soyEquipo1
                                ? bazasEquipo2 >= 1
                                : bazasEquipo1 >= 1,
                          ),
                          const SizedBox(width: 8),
                          IndicadorBaza(
                            ganada: soyEquipo1
                                ? bazasEquipo2 >= 2
                                : bazasEquipo1 >= 2,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Valor de la Ronda
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colores.acento.withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          "1", // Valor de la ronda
                          style: EstilosTexto.tituloMedio.copyWith(
                            color: Colores.acento,
                            fontWeight: FontWeight.bold,
                            fontSize: esPantallaPequena
                                ? 16
                                : (esPantallaIntermedia ? 18 : 20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Indicadores Mi Equipo (Abajo)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IndicadorBaza(
                            ganada: soyEquipo1
                                ? bazasEquipo1 >= 1
                                : bazasEquipo2 >= 1,
                          ),
                          const SizedBox(width: 8),
                          IndicadorBaza(
                            ganada: soyEquipo1
                                ? bazasEquipo1 >= 2
                                : bazasEquipo2 >= 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: esMuyAlta ? 40 : (esPantallaPequena ? 4 : 18)),

                // Botón Cambiar
                BotonMesa(
                  icon: Icons.change_circle,
                  label: TextoPartida.cambiar,
                  onTap: onCambiar ?? () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Painter para dibujar el fondo de la mesa con la forma del botón si es necesario.
class _MesaPainter extends CustomPainter {
  final double gapWidth;
  final double buttonHeight;
  final double buttonRadius;
  final Color colorFondo;
  final Color colorBorde;

  _MesaPainter({
    required this.gapWidth,
    this.buttonHeight = 35.0,
    this.buttonRadius = 17.5,
    required this.colorFondo,
    required this.colorBorde,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFondo = Paint()
      ..color = colorFondo
      ..style = PaintingStyle.fill;

    final paintBorde = Paint()
      ..color = colorBorde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();
    const double radius = 20.0;

    // Empezamos top-left (después de la curva)
    path.moveTo(0, radius);

    // Curva Top-Left
    path.quadraticBezierTo(0, 0, radius, 0);

    // Línea Superior
    path.lineTo(size.width - radius, 0);

    // Curva Top-Right
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Línea Derecha
    path.lineTo(size.width, size.height - radius);

    // Curva Bottom-Right
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // Línea Inferior con posible hueco para botón
    if (gapWidth > 0) {
      final centerX = size.width / 2;
      final double btnRealWidth = gapWidth - 10;
      final double btnRealRadius = buttonRadius;
      final btnRight = centerX + (btnRealWidth / 2);
      final btnLeft = centerX - (btnRealWidth / 2);

      // 1. Línea hasta el borde derecho del botón
      path.lineTo(btnRight, size.height);

      // 2. Dibujar contorno del botón (panza abajo)
      path.arcToPoint(
        Offset(btnRight - btnRealRadius, size.height + btnRealRadius),
        radius: Radius.circular(btnRealRadius),
        clockwise: true,
      );

      path.lineTo(btnLeft + btnRealRadius, size.height + btnRealRadius);

      path.arcToPoint(
        Offset(btnLeft, size.height),
        radius: Radius.circular(btnRealRadius),
        clockwise: true,
      );

      path.lineTo(radius, size.height);
    } else {
      path.lineTo(radius, size.height);
    }

    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.close();
    canvas.drawPath(path, paintFondo);

    canvas.drawPath(path, paintBorde);
  }

  @override
  bool shouldRepaint(covariant _MesaPainter oldDelegate) {
    return oldDelegate.gapWidth != gapWidth ||
        oldDelegate.buttonHeight != buttonHeight ||
        oldDelegate.colorFondo != colorFondo ||
        oldDelegate.colorBorde != colorBorde;
  }
}
