import 'package:flutter/material.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../widgets/crear_partida_overlay.dart';

/// Pantalla para crear una nueva partida.
class PantallaCrearPartida extends StatelessWidget {
  const PantallaCrearPartida({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      mostrarTitulo: true,
      // Contenido principal (Overlay)
      child: const Center(child: CrearPartidaOverlay()),
    );
  }
}
