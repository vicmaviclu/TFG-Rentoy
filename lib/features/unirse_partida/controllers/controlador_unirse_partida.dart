import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../perfil/controllers/controlador_perfil.dart';

/// Controlador para unirse a partidas existentes.
class ControladorUnirsePartida extends ChangeNotifier {
  final ServicioRealtime _servicio = ServicioRealtime();
  final ControladorPerfil _perfil = ControladorPerfil();

  bool cargando = false;

  // Obtiene el nombre del jugador
  String get nombreJugador {
    final perfilName = _perfil.controladorNombreUsuario.text.trim();
    if (perfilName.isNotEmpty) return perfilName;
    final user = _perfil.usuario as User?;
    if (user == null) return 'Jugador';
    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : 'Jugador';
  }

  Future<void> cargarPerfil() => _perfil.cargarPerfil();

  // Busca una sesión por PIN y se une a ella
  Future<Map<String, dynamic>> unirsePorPin(String pin) async {
    cargando = true;
    notifyListeners();
    try {
      final datosSesion = await _servicio.buscarSesionPorPin(pin);
      final idSesion = datosSesion['id'] as String;
      await _servicio.unirASesion(idSesion, nombreJugador);
      return datosSesion;
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
