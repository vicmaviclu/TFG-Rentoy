import 'package:flutter/material.dart';
import '../../../core/constantes/tamanos.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/recursos.dart';

/// Botón para iniciar sesión con Google.
class BotonGoogle extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  /// Si es true, el botón usará todo el ancho disponible.
  final bool fullWidth;

  /// Altura opcional del botón
  final double? height;

  /// Tamaño opcional del icono.
  final double? iconSize;

  /// Estilo de texto opcional para la etiqueta.
  final TextStyle? textStyle;

  const BotonGoogle({
    super.key,
    this.isLoading = false,
    required this.onPressed,
    this.label = TextoAuth.continuarConGoogle,
    this.fullWidth = false,
    this.height,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedIconSize = iconSize ?? 30.0;
    final double resolvedHeight = height ?? Tamanos.buttonHeight;
    final btn = ElevatedButton.icon(
      // Icono de carga o logo de Google
      icon: isLoading
          ? SizedBox(
              width: resolvedIconSize,
              height: resolvedIconSize,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colores.blanco,
              ),
            )
          : Image.asset(
              Recursos.iconoGoogle,
              height: resolvedIconSize,
              width: resolvedIconSize,
            ),
      // Etiqueta del botón
      label: Text(
        isLoading ? TextoAuth.iniciando : label,
        style:
            textStyle ??
            EstilosTexto.cuerpo.copyWith(
              fontWeight: FontWeight.w600,
              color: Colores.textoPrimario,
            ),
      ),
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colores.blanco,
        foregroundColor: Colores.textoPrimario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: 4,
        minimumSize: fullWidth
            ? Size(double.infinity, resolvedHeight)
            : Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: resolvedHeight,
        child: btn,
      );
    }

    return SizedBox(
      height: resolvedHeight,
      child: Center(child: btn),
    );
  }
}
