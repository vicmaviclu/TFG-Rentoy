import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/sesion_model.dart';
import '../../../models/usuario_model.dart';

class ControladorSalaEspera {
  final ServicioRealtime _servicio;
  final FirebaseAuth _auth;

  ControladorSalaEspera({ServicioRealtime? servicio, FirebaseAuth? auth})
    : _servicio = servicio ?? ServicioRealtime(),
      _auth = auth ?? FirebaseAuth.instance;

  bool esAnfitrion(String nombreAnfitrion) {
    final usuario = _auth.currentUser;
    return usuario != null && nombreAnfitrion == usuario.displayName;
  }

  Stream<List<UsuarioModel>> streamJugadores(
    String idSesion,
    int maxJugadores,
  ) {
    return _servicio.streamSesion(idSesion).map((evento) {
      final val = evento.snapshot.value;
      if (val == null || val is! Map) {
        return List<UsuarioModel>.generate(
          maxJugadores,
          (_) => UsuarioModel(uid: '', email: '', nombreUsuario: '', avatar: 1),
        );
      }

      final sesion = SesionModel.fromMap(val, idSesion);
      final jugadores = List<UsuarioModel>.generate(
        maxJugadores,
        (_) => UsuarioModel(uid: '', email: '', nombreUsuario: '', avatar: 1),
      );

      for (var i = 1; i <= maxJugadores; i++) {
        final clave = 'jugador $i';
        if (!sesion.jugadores.containsKey(clave)) {
          continue;
        }
        final v = sesion.jugadores[clave];
        if (v == null) {
          continue;
        }

        if (v is String) {
          // Si solo es string (nombre), usamos dummy para lo demás
          jugadores[i - 1] = UsuarioModel(
            uid: '',
            email: '',
            nombreUsuario: v,
            avatar: 1, // Default avatar
          );
        } else if (v is Map) {
          jugadores[i - 1] = UsuarioModel(
            uid: v['uid']?.toString() ?? '',
            email: v['email']?.toString() ?? '',
            nombreUsuario: v['name']?.toString() ?? '',
            avatar: (v['avatar'] is int)
                ? v['avatar'] as int
                : int.tryParse(v['avatar']?.toString() ?? '') ?? 1,
          );
        }
      }

      return jugadores;
    }).asBroadcastStream();
  }

  /// Pide al servicio que tome un hueco específico (delegado)
  Future<void> tomarHueco(String idSesion, int hueco) async {
    try {
      return await _servicio.tomarHueco(idSesion, hueco);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream con el snapshot completo de la sesión (DatabaseEvent)
  Stream<DatabaseEvent> streamEventoSesion(String idSesion) =>
      _servicio.streamSesion(idSesion).asBroadcastStream();

  /// Pide al servicio cancelar la sesion (eliminar)
  Future<void> cancelarSesion(String idSesion) async {
    try {
      await _servicio.cancelarSesion(idSesion);
    } catch (e) {
      rethrow;
    }
  }

  /// Pide al servicio que haga salir al usuario de la sesion (eliminar su entrada)
  Future<void> salirDeSesion(String idSesion) async {
    try {
      await _servicio.salirDeSesion(idSesion);
    } catch (e) {
      rethrow; // Let the UI handle the error (showing snackbar etc)
    }
  }
}
