import 'package:flutter/material.dart';

import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/recursos.dart';
import '../../../core/widgets/contenedor_principal.dart';

/// Contraseña del modal para mostrar las reglas del juego.
class ReglasJuegoOverlay extends StatefulWidget {
  const ReglasJuegoOverlay({super.key});

  @override
  State<ReglasJuegoOverlay> createState() => _ReglasJuegoOverlayState();
}

class _ReglasJuegoOverlayState extends State<ReglasJuegoOverlay> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irASiguiente() {
    if (_paginaActual < Recursos.paginasDeReglas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _irAAnterior() {
    if (_paginaActual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTextoConNegritas(String texto) {
    if (!texto.contains('**')) {
      return Text(texto, style: EstilosTexto.cuerpo.copyWith(height: 1.5));
    }

    final spans = <TextSpan>[];
    final partes = texto.split('**');

    for (int i = 0; i < partes.length; i++) {
      if (i % 2 == 0) {
        // Texto normal
        spans.add(TextSpan(text: partes[i]));
      } else {
        // Texto en negrita
        spans.add(
          TextSpan(
            text: partes[i],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: EstilosTexto.cuerpo.copyWith(height: 1.5),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0,
      ),
      backgroundColor: Colores.transparente,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ContenedorPrincipal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título y botón cerrar
              Row(
                children: [
                  Expanded(
                    child: Text(
                      TextoReglas.tituloOverlay,
                      style: EstilosTexto.tituloMedio.copyWith(
                        color: Colores.blanco,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colores.blanco),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Indicador de página
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  Recursos.paginasDeReglas.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _paginaActual == index
                          ? Colores.secundario
                          : Colores.textoSecundario.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // PageView con altura fija para evitar espacios redundantes
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _paginaActual = index;
                    });
                  },
                  itemCount: Recursos.paginasDeReglas.length,
                  itemBuilder: (context, index) {
                    final pagina = Recursos.paginasDeReglas[index];
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colores.superficie,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pagina['titulo']!,
                              style: EstilosTexto.tituloPequeno.copyWith(
                                color: Colores.secundario,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (pagina.containsKey('imagen')) ...[
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    pagina['imagen']!,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextoConNegritas(pagina['contenido']!),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Botones de navegación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Anterior
                  TextButton.icon(
                    onPressed: _paginaActual > 0 ? _irAAnterior : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: const Text(TextoReglas.btnAnterior),
                    style: TextButton.styleFrom(
                      foregroundColor: Colores.textoPrimario,
                      disabledForegroundColor: Colores.textoSecundario
                          .withValues(alpha: 0.5),
                    ),
                  ),

                  // Botón Siguiente o Cerrar
                  if (_paginaActual < Recursos.paginasDeReglas.length - 1)
                    TextButton.icon(
                      onPressed: _irASiguiente,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text(TextoReglas.btnSiguiente),
                      style: TextButton.styleFrom(
                        foregroundColor: Colores.secundario,
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.secundario,
                        foregroundColor: Colores.textoPrimario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        TextoReglas.btnCerrar,
                        style: EstilosTexto.boton,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
