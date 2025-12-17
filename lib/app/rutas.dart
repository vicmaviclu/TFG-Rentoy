import 'package:flutter/widgets.dart';
import '../features/auth/screens/pantalla_login.dart';
import '../features/auth/screens/pantalla_registro.dart';
import '../features/home/screens/home_screen.dart';
import '../features/crear_partida/screens/pantalla_crear_partida.dart';
import '../features/unirse_partida/screens/pantalla_unirse_partida.dart';
import '../features/plantilla/screens/pantalla_plantilla.dart';

/// Rutas globales de la aplicación.
///
/// Usamos nombres en español para las rutas principales.
class RutasApp {
  static const String inicio = '/inicio';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String crearPartida = '/crear_partida';
  static const String unirsePartida = '/unirse_partida';
  static const String plantilla = '/plantilla';

  static Map<String, WidgetBuilder> get todas {
    return {
      login: (c) => const PantallaLogin(),
      registro: (c) => const PantallaRegistro(),
      inicio: (c) => const HomeScreen(),
      crearPartida: (c) => const PantallaCrearPartida(),
      unirsePartida: (c) => const PantallaUnirsePartida(),
      plantilla: (c) => const PantallaPlantilla(),
    };
  }
}
