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
    this.logoSize = Tamanos.logoSize,
    this.title = TextoComun.nombreApp,
    this.subtitle = TextoComun.subtitulo,
    this.showSubtitle = true,
    this.showBackButton = false,
  });

  final double logoSize;
  final String title;
  final String subtitle;
  final bool showSubtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBackButton)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        Container(
          width: logoSize,
          height: logoSize,
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
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: EstilosTexto.titulo.copyWith(color: Colores.textoPrimario),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        if (showSubtitle)
          Text(
            subtitle,
            style: EstilosTexto.cuerpo.copyWith(color: Colores.textoSecundario),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
