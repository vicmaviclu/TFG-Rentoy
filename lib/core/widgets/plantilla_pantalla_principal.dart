import 'package:flutter/material.dart';
import '../../features/perfil/widgets/boton_avatar.dart';
import '../../app/rutas.dart';
import '../constantes/recursos.dart';
import 'pagina_fondo.dart';
import 'contenedor_principal.dart';

/// Widget envoltorio que implementa el diseño de "Sala de Espera":
/// - Fondo degradado verde (vía PaginaFondo).
/// - LayoutBuilder para calcular tamaño del logo y posición de la tarjeta.
/// - Logo flotante en la parte superior central.
/// - ContenedorPrincipal (Tarjeta Verde) que contiene el [child].
/// - [onBack] opcional para navegación (renderiza botón de volver).
/// - [showAvatar] opcional para mostrar botón de avatar (default false).
class PlantillaPantallaPrincipal extends StatelessWidget {
  final Widget child;
  final bool mostrarVolver;
  final bool mostrarAvatar;
  final VoidCallback? alVolver;

  const PlantillaPantallaPrincipal({
    super.key,
    required this.child,
    this.mostrarVolver = false,
    this.mostrarAvatar = false,
    this.alVolver,
  });

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      mostrarTitulo: false, // Manejamos el logo nosotros mismos
      conScroll: false,

      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;

          final bool esPantallaPequena = totalW < 400;
          double logoSize = (totalW * 0.45).clamp(100.0, 280.0);
          final double cardTopMargin = logoSize * 0.5;

          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: totalW),
                child: IntrinsicHeight(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // 2. Contenedor de Tarjeta Principal
                      Padding(
                        padding: EdgeInsets.only(
                          top: cardTopMargin + 4,
                          left: 10, // Margen reducido
                          right: 10, // Margen reducido
                          bottom: 20,
                        ),
                        child: ContenedorPrincipal(
                          // Usar todo el ancho disponible (menos padding)
                          width: totalW - 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Fila de Botón de Volver (Integrado en la tarjeta)
                              if (mostrarVolver)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed:
                                          alVolver ??
                                          () => Navigator.of(context).pop(),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ),

                              // Contenido
                              child,
                            ],
                          ),
                        ),
                      ),

                      // 3. Logo Flotante (Arriba Centro)
                      Positioned(
                        top: 0, // Relativo al top del Stack
                        child: Image.asset(
                          Recursos.logo,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 4. Botón de Avatar (Arriba Derecha)
                      if (mostrarAvatar)
                        Positioned(
                          top: esPantallaPequena ? 10 : 25,
                          right: esPantallaPequena ? 16 : 35,
                          child: BotonAvatar(
                            radius: esPantallaPequena ? 25 : 35,
                            onTap: () =>
                                Navigator.pushNamed(context, RutasApp.perfil),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
