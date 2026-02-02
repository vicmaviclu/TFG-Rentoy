import 'package:flutter/material.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../controllers/controlador_partida.dart';

class MesaJuego extends StatelessWidget {
  final ControladorPartida? controlador;
  final String? idSesion;
  final bool mostrarBotonLanzar;
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
    const double kAlturaBoton = 45.0;
    const double kAnchoBoton = 140.0;
    const double kProtrusion = 22.5; // Mitad del botón sale de la mesa visual
    const double kMargin = 16.0; // Margen visual deseado

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. La Mesa Visual (Fondo + Borde + Contenido)
        // La colocamos con 'Positioned' para dejar espacio real abajo para el botón.
        // Así el Stack padre crece lo suficiente para contener el botón.
        Positioned(
          top: kMargin,
          left: kMargin,
          right: kMargin,
          bottom:
              kMargin +
              kProtrusion, // Dejamos espacio abajo para la mitad del botón
          child: CustomPaint(
            painter: _MesaPainter(
              gapWidth: mostrarBotonLanzar
                  ? kAnchoBoton + 10
                  : 0, // +10 de margen visual
              colorFondo: Colores.primario.withOpacity(0.5),
              colorBorde: Colores.blanco24,
            ),
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // Título
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Mesa de Juego',
                      style: EstilosTexto.tituloMedio.copyWith(
                        color: Colores.blanco24,
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

                          if (numero == '0' || palo.isEmpty)
                            return const SizedBox.shrink();

                          final prefijo = palo[0];
                          final path =
                              'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Ganando: $jugador",
                                  style: EstilosTexto.caption.copyWith(
                                    color: Colores.blanco,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Image.asset(
                                  path,
                                  width: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
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
            ),
          ),
        ),

        // 2. Botón Lanzar
        // Lo colocamos alineado abajo del todo (dentro del kMargin + kProtrusion reservado)
        // Su centro vertical debe coincidir con el bottom de la mesa visual.
        // Mesa visual bottom = Height - (kMargin + kProtrusion)
        // Botón Height = 45. Center = 22.5
        // Si ponemos bottom: kMargin, el botón empieza en kMargin desde abajo.
        // Height = 45. Top = kMargin + 45.
        // Queremos que el CENTRO del botón esté en (kMargin + kProtrusion).
        // CenterY = kMargin + 22.5.
        // Bottom = CenterY - HalfHeight = (kMargin + 22.5) - 22.5 = kMargin.
        if (mostrarBotonLanzar)
          Positioned(
            bottom: kMargin,
            left: 0,
            right: 0,
            height: kAlturaBoton, // Forzamos altura para asegurar hit test
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
                      side: BorderSide.none, // El borde lo dibuja el Painter
                    ),
                    elevation: 10,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onLanzar,
                  child: const Text(
                    'LANZAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
      // Ancho total del hueco/botón: gapWidth (aprox 140 + 10)
      // Pero el botón mide exactamente 140.
      // Ajustamos para dibujar el contorno del botón (140 width, 45 height, 22.5 radius)

      const double btnWidth = 140.0;
      // const double btnHeight = 45.0; // Unused
      const double btnRadius = 22.5; // btnHeight / 2

      final btnRight = centerX + (btnWidth / 2);
      final btnLeft = centerX - (btnWidth / 2);

      // 1. Línea hasta el borde derecho del botón
      path.lineTo(btnRight, size.height);

      // 2. Dibujar contorno del botón (panza abajo)
      // Estamos en (btnRight, centerY). CenterY del botón es size.height.
      // Arc de 90 grados hacia abajo
      // Centro del arco derecho: (btnRight - btnRadius, size.height)

      // ArcToPoint para la esquina inferior derecha del botón
      path.arcToPoint(
        Offset(btnRight - btnRadius, size.height + btnRadius),
        radius: const Radius.circular(btnRadius),
        clockwise: true,
      );

      // Línea recta inferior
      path.lineTo(btnLeft + btnRadius, size.height + btnRadius);

      // ArcToPoint para la esquina inferior izquierda (subida)
      path.arcToPoint(
        Offset(btnLeft, size.height),
        radius: const Radius.circular(btnRadius),
        clockwise: true,
      );

      // Ahora estamos en el borde izquierdo del botón, listos para seguir con la mesa
      path.lineTo(radius, size.height);
    } else {
      // Sin hueco, línea completa
      path.lineTo(radius, size.height);
    }

    // Curva Bottom-Left
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Cierre
    path.close();

    // Dibujar fondo
    canvas.drawPath(path, paintFondo);

    // Dibujar borde
    canvas.drawPath(path, paintBorde);
  }

  @override
  bool shouldRepaint(covariant _MesaPainter oldDelegate) {
    return oldDelegate.gapWidth != gapWidth ||
        oldDelegate.colorFondo != colorFondo ||
        oldDelegate.colorBorde != colorBorde;
  }
}
