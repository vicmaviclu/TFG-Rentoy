import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/constantes/cadenas.dart';
import '../../perfil/controllers/controlador_perfil.dart';

/// Controlador para la creación de partidas.
class ControladorCrearPartida extends ChangeNotifier {
  final ServicioRealtime _servicio = ServicioRealtime();
  final ControladorPerfil _perfil = ControladorPerfil();

  int maxJugadores = 2;
  bool cargando = false;

  // Obtiene el nombre del anfitrión desde el perfil o Auth
  String get nombreAnfitrion {
    final perfilName = _perfil.controladorNombreUsuario.text.trim();
    if (perfilName.isNotEmpty) return perfilName;
    final user = _perfil.usuario as User?;
    if (user == null) return TextoPerfil.jugadorDefecto;
    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : TextoPerfil.jugadorDefecto;
  }

  // Carga los datos del perfil de usuario
  Future<void> cargarPerfil() => _perfil.cargarPerfil();

  // Crea una nueva sesión de juego y retorna su ID
  Future<String> crearSesion() async {
    final nombre = nombreAnfitrion;
    cargando = true;
    notifyListeners();
    try {
      final id = await _servicio.crearSesion(
        hostName: nombre,
        maxPlayers: maxJugadores,
        avatar: _perfil.avatarSeleccionado,
      );
      return id;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _perfil.dispose();
    super.dispose();
  }
}
