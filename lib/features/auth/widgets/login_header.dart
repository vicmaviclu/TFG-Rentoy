import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';

/// Header for the login screen: logo + app name + subtitle.
///
/// Presentational widget extracted from `pantalla_login.dart` so
/// the screen file only contains layout and navigation logic.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.12), blurRadius: 6, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset('assets/images/logo_rentoy.jpg', width: 96, height: 96, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Text(AppStrings.appName, style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(AppStrings.subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
