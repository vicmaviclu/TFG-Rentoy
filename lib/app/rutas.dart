import 'package:flutter/widgets.dart';
import '../features/auth/screens/pantalla_login.dart';
import '../features/auth/screens/pantalla_registro.dart';
import '../features/home/screens/home_screen.dart';

/// Rutas globales de la aplicación.
///
/// Usamos nombres en español para las rutas principales.
class RutasApp {
  static const String inicio = '/inicio';
  static const String login = '/login';
  static const String registro = '/registro';

  static Map<String, WidgetBuilder> get todas {
    return {
      login: (c) => const PantallaLogin(),
      registro: (c) => const PantallaRegistro(),
      inicio: (c) => const HomeScreen(),
    };
  }
}
