import 'package:flutter/material.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../widgets/crear_partida_overlay.dart';

/// Fallback pantalla completa: si el overlay se abre por navegación, mostramos
/// el mismo contenido centrado.
class PantallaCrearPartida extends StatelessWidget {
  const PantallaCrearPartida({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      showTitle: true,
      child: const Center(child: CrearPartidaOverlay()),
    );
  }
}
