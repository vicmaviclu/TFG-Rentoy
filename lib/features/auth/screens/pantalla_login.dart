import 'package:flutter/material.dart';

import '../../../core/widgets/boton_google.dart';
import '../../../core/widgets/fondo_cartas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/tamanos.dart';
import '../../../core/constantes/cadenas.dart';
import '../controllers/controlador_login.dart';
import '../../../app/rutas.dart';

import '../widgets/login_header.dart';
import '../widgets/credentials_form.dart';

/// Pantalla de inicio de sesión (presentación y navegación).
///
/// Esta pantalla delega la parte visual a widgets en
/// `features/auth/widgets/` y mantiene la lógica de navegación y
/// controladores.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final ControladorLogin controller;

  @override
  void initState() {
    super.initState();
    controller = ControladorLogin();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo reutilizable
            const FondoCartas(),

            // Watermark con logo grande y semitransparente
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_rentoy.jpg',
                      width: size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Contenido central
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 8),
                    // App title (puede quedar aquí o en el header si se desea)
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Card central con formulario: limitar alto para evitar overflow
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: size.height * 0.78),
                      child: SizedBox(
                        width: size.width < 600 ? size.width * 0.92 : 700,
                        child: Material(
                          elevation: 8,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.12), width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const LoginHeader(),
                                  const SizedBox(height: 6),

                                  // Formulario delegando la lógica al controlador
                                  CredentialsForm(controller: controller),

                                  const SizedBox(height: 5),
                                  Text('o', style: AppTextStyles.subheading.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                                  const SizedBox(height: 1),

                                  AnimatedBuilder(
                                    animation: controller,
                                    builder: (context, _) {
                                      return Center(
                                        child: BotonGoogle(
                                          isLoading: controller.cargando,
                                          onPressed: () async {
                                            final err = await controller.iniciarSesionConGoogle();
                                            if (err != null) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                                            }
                                          },
                                          fullWidth: false,
                                          label: AppStrings.googleSignIn,
                                          height: 54,
                                          iconSize: 30,
                                          textStyle: AppTextStyles.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 6),
                                  TextButton(
                                    onPressed: controller.cargando
                                        ? null
                                        : () {
                                            Navigator.of(context).pushNamed(RutasApp.registro);
                                          },
                                    child: const Text(AppStrings.noTienesCuenta),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
