import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/recursos.dart';
import 'package:firebase_database/firebase_database.dart';
import '../controllers/controlador_partida.dart';

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

  /// Callback cuando se presiona el botón de cambiar
  final VoidCallback? onCambiar;

  const MesaJuego({
    super.key,
    this.controlador,
    this.idSesion,
    this.mostrarBotonLanzar = false,
    this.onLanzar,
    this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    const double kAlturaBoton = 35.0;
    const double kAnchoBoton = 110.0;
    const double kProtrusion = 18.0;
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
              gapWidth: mostrarBotonLanzar ? kAnchoBoton + 10 : 0,
              colorFondo: Colores.primario.withValues(alpha: 0.5),
              colorBorde: Colores.blanco24,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular tamaño de carta basado en el alto disponible de la mesa
                final double altoDisponible = constraints.maxHeight;

                final double cartaHeight = altoDisponible * 0.75;
                final double cartaWidth = cartaHeight * (2 / 3);

                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      // Título (Fondo Centrado)
                      Align(
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: 0.3, // Un poco más sutil ya que está detrás
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
                        Stack(
                          children: [
                            // --- IZQUIERDA: BOTONES + MUESTRA ---
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botones
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _BotonMesa(
                                        icon: Icons.mic,
                                        label: TextoPartida.cantar,
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 12),
                                      _BotonMesa(
                                        icon: Icons.change_circle,
                                        label: TextoPartida.cambiar,
                                        onTap: onCambiar ?? () {},
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),

                                  // Muestra
                                  StreamBuilder<Map<String, dynamic>>(
                                    stream: controlador!.streamCartaMuestra(
                                      idSesion!,
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return SizedBox(
                                          width: cartaWidth,
                                          height: cartaHeight,
                                        );
                                      }
                                      final muestra = snapshot.data!;
                                      final numero =
                                          muestra['numero']?.toString() ?? '0';
                                      final palo =
                                          muestra['palo']?.toString() ?? '';
                                      final path = Recursos.obtenerCarta(
                                        palo,
                                        numero,
                                      );

                                      if (path.isEmpty) {
                                        return SizedBox(
                                          width: cartaWidth,
                                          height: cartaHeight,
                                        );
                                      }

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              TextoPartida.muestra,
                                              style: EstilosTexto.subtitulo
                                                  .copyWith(
                                                    color: Colores.blanco,
                                                    fontSize:
                                                        (altoDisponible * 0.035)
                                                            .clamp(10.0, 14.0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.asset(
                                                path,
                                                width: cartaWidth,
                                                height: cartaHeight,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // --- CENTRO: INFORMACIÓN DE RONDA (Centrado) ---
                            Align(
                              alignment: Alignment.center,
                              child: StreamBuilder<DatabaseEvent>(
                                stream: controlador!.streamPartida(
                                  idSesion ?? '',
                                ),
                                builder: (context, snapshot) {
                                  String textoRonda = "${TextoPartida.ronda} 1";
                                  if (snapshot.hasData &&
                                      snapshot.data!.snapshot.value is Map) {
                                    final val =
                                        snapshot.data!.snapshot.value as Map;
                                    if (val['rondas'] != null &&
                                        val['rondas']['actual'] != null) {
                                      textoRonda =
                                          "${TextoPartida.ronda} ${val['rondas']['actual']}";
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
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Indicadores Equipo 2 (Arriba)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _IndicadorBaza(),
                                          const SizedBox(width: 8),
                                          _IndicadorBaza(),
                                        ],
                                      ),

                                      // Valor de la Ronda
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colores.acento.withValues(
                                                alpha: 0.8,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          child: Text(
                                            "1", // Valor de la ronda
                                            style: EstilosTexto.tituloMedio
                                                .copyWith(
                                                  color: Colores.acento,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                          ),
                                        ),
                                      ),

                                      // Indicadores Equipo 1 (Abajo)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _IndicadorBaza(),
                                          const SizedBox(width: 8),
                                          _IndicadorBaza(),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // --- DERECHA: CARTA GANADORA ---
                            Align(
                              alignment: Alignment.centerRight,
                              child: StreamBuilder<Map<String, dynamic>>(
                                stream: controlador!.streamCartaGanadora(
                                  idSesion!,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return SizedBox(
                                      width: cartaWidth,
                                      height: cartaHeight,
                                    );
                                  }

                                  final dataGanadora = snapshot.data!;
                                  final carta = dataGanadora['carta'];
                                  final jugador =
                                      dataGanadora['jugador']?.toString() ?? '';

                                  if (carta is! Map) {
                                    return SizedBox(
                                      width: cartaWidth,
                                      height: cartaHeight,
                                    );
                                  }

                                  final numero =
                                      carta['numero']?.toString() ?? '0';
                                  final palo = carta['palo']?.toString() ?? '';
                                  final path = Recursos.obtenerCarta(
                                    palo,
                                    numero,
                                  );

                                  if (path.isEmpty) {
                                    return SizedBox(
                                      width: cartaWidth,
                                      height: cartaHeight,
                                    );
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "${TextoPartida.ganando} $jugador",
                                          style: EstilosTexto.subtitulo
                                              .copyWith(
                                                color: Colores.blanco,
                                                fontSize:
                                                    (altoDisponible * 0.035)
                                                        .clamp(10.0, 14.0),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            path,
                                            width: cartaWidth,
                                            height: cartaHeight,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) =>
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Botón Lanzar
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
                  child: const Text(
                    TextoPartida.btnLanzar,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
}

class _MesaPainter extends CustomPainter {
  final double gapWidth;
  final Color colorFondo;
  final Color colorBorde;

  _MesaPainter({
    required this.gapWidth,
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

    // Línea Inferior
    if (gapWidth > 0) {
      final centerX = size.width / 2;

      const double btnWidth = 110.0;
      const double btnRadius = 17.5;

      final btnRight = centerX + (btnWidth / 2);
      final btnLeft = centerX - (btnWidth / 2);

      // 1. Línea hasta el borde derecho del botón
      path.lineTo(btnRight, size.height);

      // 2. Dibujar contorno del botón (panza abajo)
      path.arcToPoint(
        Offset(btnRight - btnRadius, size.height + btnRadius),
        radius: const Radius.circular(btnRadius),
        clockwise: true,
      );

      path.lineTo(btnLeft + btnRadius, size.height + btnRadius);

      path.arcToPoint(
        Offset(btnLeft, size.height),
        radius: const Radius.circular(btnRadius),
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
        oldDelegate.colorFondo != colorFondo ||
        oldDelegate.colorBorde != colorBorde;
  }
}

class _BotonMesa extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BotonMesa({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colores.primario.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colores.blanco54, width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IndicadorBaza extends StatelessWidget {
  const _IndicadorBaza();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colores.blanco, // Siempre blanco
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
