import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/recursos.dart';
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

  const MesaJuego({
    super.key,
    this.controlador,
    this.idSesion,
    this.mostrarBotonLanzar = false,
    this.onLanzar,
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
          top: kMargin,
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
                  child: Stack(
                    children: [
                      // Título
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          TextoPartida.mesaDeJuego,
                          style: EstilosTexto.tituloMedio.copyWith(
                            color: Colores.blanco24,
                            fontSize: altoDisponible * 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Carta ganadora
                      if (controlador != null && idSesion != null)
                        Positioned.fill(
                          child: StreamBuilder<Map<String, dynamic>>(
                            stream: controlador!.streamCartaGanadora(idSesion!),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final dataGanadora = snapshot.data!;
                              final carta = dataGanadora['carta'];
                              final jugador =
                                  dataGanadora['jugador']?.toString() ?? '';

                              if (carta is! Map) return const SizedBox.shrink();

                              final numero = carta['numero']?.toString() ?? '0';
                              final palo = carta['palo']?.toString() ?? '';

                              final path = Recursos.obtenerCarta(palo, numero);
                              if (path.isEmpty) return const SizedBox.shrink();

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Texto "Ganando: ..."
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${TextoPartida.ganando} $jugador",
                                        style: EstilosTexto.subtitulo.copyWith(
                                          color: Colores.blanco,
                                          fontSize: (altoDisponible * 0.035)
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
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
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
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 2. Botón Lanzar
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
