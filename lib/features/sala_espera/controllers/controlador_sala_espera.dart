import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/sesion_model.dart';
import '../../../models/usuario_model.dart';

class SalaEsperaController {
  final ServicioRealtime _servicio;

  SalaEsperaController({ServicioRealtime? servicio})
    : _servicio = servicio ?? ServicioRealtime();

  Stream<List<UsuarioModel>> playersStream(String sessionId, int maxPlayers) {
    return _servicio.streamSesion(sessionId).map((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) {
        return List<UsuarioModel>.generate(
          maxPlayers,
          (_) => UsuarioModel(uid: '', email: '', nombreUsuario: '', avatar: 1),
        );
      }

      final sesion = SesionModel.fromMap(val, sessionId);
      final players = List<UsuarioModel>.generate(
        maxPlayers,
        (_) => UsuarioModel(uid: '', email: '', nombreUsuario: '', avatar: 1),
      );

      for (var i = 1; i <= maxPlayers; i++) {
        final key = 'jugador $i';
        if (!sesion.jugadores.containsKey(key)) {
          continue;
        }
        final v = sesion.jugadores[key];
        if (v == null) {
          continue;
        }

        if (v is String) {
          // Si solo es string (nombre), usamos dummy para lo demás
          players[i - 1] = UsuarioModel(
            uid: '',
            email: '',
            nombreUsuario: v,
            avatar: 1, // Default avatar
          );
        } else if (v is Map) {
          players[i - 1] = UsuarioModel(
            uid: v['uid']?.toString() ?? '',
            email: v['email']?.toString() ?? '',
            nombreUsuario: v['name']?.toString() ?? '',
            avatar: (v['avatar'] is int)
                ? v['avatar'] as int
                : int.tryParse(v['avatar']?.toString() ?? '') ?? 1,
          );
        }
      }

      return players;
    }).asBroadcastStream();
  }

  /// Pide al servicio que tome un hueco específico (delegado)
  Future<void> tomarHueco(String sessionId, int slot) async {
    try {
      return await _servicio.tomarHueco(sessionId, slot);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream con el snapshot completo de la sesión (DatabaseEvent)
  Stream<DatabaseEvent> sessionStream(String sessionId) =>
      _servicio.streamSesion(sessionId).asBroadcastStream();

  /// Pide al servicio cancelar la sesion (eliminar)
  Future<void> cancelarSesion(String sessionId) async {
    try {
      await _servicio.cancelarSesion(sessionId);
    } catch (e) {
      rethrow;
    }
  }

  /// Pide al servicio que haga salir al usuario de la sesion (eliminar su entrada)
  Future<void> salirDeSesion(String sessionId) async {
    try {
      await _servicio.salirDeSesion(sessionId);
    } catch (e) {
      rethrow; // Let the UI handle the error (showing snackbar etc)
    }
  }
}
