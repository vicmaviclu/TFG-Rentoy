import '../../servicios/servicio_realtime.dart';

/// Wrapper de compatibilidad que reexpone la API anterior en inglés.
class RealtimeService {
  final ServicioRealtime _servicio = ServicioRealtime();

  Future<String> createSession({required String hostName, required int maxPlayers}) => _servicio.crearSesion(hostName: hostName, maxPlayers: maxPlayers);

  Stream sessionStream(String sessionId) => _servicio.streamSesion(sessionId);

  Future<void> joinSession(String sessionId, String playerName) => _servicio.unirASesion(sessionId, playerName);
}
