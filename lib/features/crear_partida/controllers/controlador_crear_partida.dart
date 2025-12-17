import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/realtime_service.dart';
import '../../perfil/controllers/controlador_perfil.dart';

/// Controlador que encapsula la lógica de crear una partida. Obtiene el
/// nombre del perfil (si existe) y delega la creación en `RealtimeService`.
class ControladorCrearPartida extends ChangeNotifier {
  final RealtimeService _servicio = RealtimeService();
  final ControladorPerfil _perfil = ControladorPerfil();

  int maxPlayers = 2;
  bool cargando = false;

  /// Nombre a usar como host (obtiene del perfil, o de FirebaseAuth).
  String get hostName {
    final perfilName = _perfil.controladorNombreUsuario.text.trim();
    if (perfilName.isNotEmpty) return perfilName;
    final user = _perfil.usuario as User?;
    if (user == null) return 'Jugador';
    return user.displayName?.trim().isEmpty == false ? user.displayName! : (user.email ?? user.uid);
  }

  /// Precarga perfil (intenta cargar valores guardados en Firestore).
  Future<void> cargarPerfil() => _perfil.cargarPerfil();

  /// Crea la sesión y devuelve el id/código.
  Future<String> crearSesion() async {
    await cargarPerfil();
    final nombre = hostName;
    cargando = true;
    notifyListeners();
    try {
      final id = await _servicio.createSession(hostName: nombre, maxPlayers: maxPlayers);
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
