import 'package:flutter/material.dart';
import '../constantes/tamanos.dart';
import '../constantes/cadenas.dart';
import '../constantes/textos.dart';
import '../constantes/colores.dart';

/// Botón presentacional para iniciar sesión con Google.
///
/// La lógica real de autenticación debe residir en un controlador/servicio
/// y ser invocada mediante `onPressed`. El parámetro `isLoading` controla
/// el estado visual de carga.
class BotonGoogle extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  /// Si es true, el botón usará todo el ancho disponible. Si es false,
  /// ajustará su tamaño al contenido y se centrará.
  final bool fullWidth;
  /// Altura opcional del botón (si no se proporciona se usa AppSizes.buttonHeight).
  final double? height;
  /// Tamaño opcional del icono.
  final double? iconSize;
  /// Estilo de texto opcional para la etiqueta.
  final TextStyle? textStyle;

  const BotonGoogle({
    super.key,
    this.isLoading = false,
    required this.onPressed,
    this.label = AppStrings.googleSignIn,
    this.fullWidth = false,
    this.height,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedIconSize = iconSize ?? 30.0;
    final double resolvedHeight = height ?? AppSizes.buttonHeight;
    final btn = ElevatedButton.icon(
      icon: isLoading
          ? SizedBox(
              width: resolvedIconSize,
              height: resolvedIconSize,
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Image.asset(
              'assets/images/simbolo_google.png',
              height: resolvedIconSize,
              width: resolvedIconSize,
            ),
      label: Text(
        isLoading ? AppStrings.iniciando : label,
        style: textStyle ?? AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.googleGrey,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: fullWidth ? Size(double.infinity, resolvedHeight) : Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: resolvedHeight, child: btn);
    }

    return SizedBox(height: resolvedHeight, child: Center(child: btn));
  }
}