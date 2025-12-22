import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rentoy/features/sala_espera/screens/pantalla_sala_espera.dart';
import 'package:rentoy/features/perfil/screens/pantalla_perfil.dart';
import '../features/auth/screens/pantalla_login.dart';
import '../features/auth/screens/pantalla_registro.dart';
import '../features/home/screens/pantalla_home.dart';
import '../features/crear_partida/screens/pantalla_crear_partida.dart';
import '../features/unirse_partida/screens/pantalla_unirse_partida.dart';

/// Rutas globales de la aplicación.
class RutasApp {
  static const String inicio = '/inicio';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String crearPartida = '/crear_partida';
  static const String unirsePartida = '/unirse_partida';
  static const String plantilla = '/plantilla';
  static const String salaEspera = '/sala_espera';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get rutasApp {
    return {
      login: (c) => const PantallaLogin(),
      registro: (c) => const PantallaRegistro(),
      inicio: (c) => const PantallaHome(),
      perfil: (c) => const PantallaPerfil(),
      crearPartida: (c) => const PantallaCrearPartida(),
      unirsePartida: (c) => const PantallaUnirsePartida(),
      salaEspera: (c) => _salaEsperaFromContext(c),
    };
  }

  // Helper: construye el widget de la sala de espera.
  static Widget _salaEsperaWidget(
    String idSesion,
    String nombreAnfitrion,
    int maxJugadores,
  ) {
    return PantallaSalaEspera(
      idSesion: idSesion,
      nombreAnfitrion: nombreAnfitrion,
      maxJugadores: maxJugadores,
    );
  }

  // Extrae `RouteSettings.arguments` del contexto y construye el widget.
  static Widget _salaEsperaFromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final idSesion = args['idSesion']?.toString() ?? '';
      final nombreAnfitrion = args['nombreAnfitrion']?.toString() ?? '';
      final maxJugadores = args['maxJugadores'] is int
          ? args['maxJugadores'] as int
          : int.tryParse(args['maxJugadores']?.toString() ?? '') ?? 2;
      return _salaEsperaWidget(idSesion, nombreAnfitrion, maxJugadores);
    }
    return const SizedBox.shrink();
  }
}
