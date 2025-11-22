import 'package:flutter/widgets.dart';
import '../features/auth/screens/pantalla_login.dart';
import '../features/auth/screens/register_screen.dart';

/// Rutas globales de la aplicación.
///
/// Usamos nombres en español para las rutas principales.
class RutasApp {
  static const String inicio = '/inicio';
  static const String login = '/login';
  static const String registro = '/registro';

  static Map<String, WidgetBuilder> get todas {
    return {
      login: (c) => const LoginScreen(),
      registro: (c) => const RegisterScreen(),
      // `inicio` se resuelve por el estado de autenticación en `AplicacionWidget`.
    };
  }
}
