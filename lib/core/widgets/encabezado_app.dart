import 'package:flutter/material.dart';
import '../constantes/cadenas.dart';
import '../constantes/textos.dart';
import '../constantes/colores.dart';
import '../constantes/tamanos.dart';
import '../constantes/recursos.dart';

/// Encabezado reutilizable con logo, título y subtítulo del juego.
///
/// Diseñado para usarse en la parte superior de varias pantallas.
class EncabezadoApp extends StatelessWidget {
  const EncabezadoApp({
    super.key,
    this.tamanoLogo = Tamanos.logoSize,
    this.titulo = TextoComun.nombreApp,
    this.subtitulo = TextoComun.subtitulo,
    this.mostrarSubtitulo = true,
    this.mostrarBotonVolver = false,
  });

  final double tamanoLogo;
  final String titulo;
  final String subtitulo;
  final bool mostrarSubtitulo;
  final bool mostrarBotonVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (mostrarBotonVolver)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        Container(
          width: tamanoLogo,
          height: tamanoLogo,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.12),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(
            Recursos.logo,
            width: tamanoLogo,
            height: tamanoLogo,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          titulo,
          style: EstilosTexto.titulo.copyWith(color: Colores.textoPrimario),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        if (mostrarSubtitulo)
          Text(
            subtitulo,
            style: EstilosTexto.cuerpo.copyWith(color: Colores.textoSecundario),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
