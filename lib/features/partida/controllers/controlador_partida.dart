import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/usuario_model.dart';

class ControladorPartida {
  final ServicioRealtime _servicio;

  ControladorPartida({required ServicioRealtime servicio})
    : _servicio = servicio;

  /// Escucha los cambios en la sesión/partida
  Stream<DatabaseEvent> streamPartida(String idPartida) {
    return _servicio.streamSesion(idPartida);
  }

  /// Escucha los jugadores de la partida
  Stream<List<UsuarioModel>> streamJugadores(String idPartida) {
    return _servicio.streamSesion(idPartida).map((evento) {
      final val = evento.snapshot.value;
      if (val == null || val is! Map) {
        return <UsuarioModel>[];
      }

      final sesion = val;
      Map<String, dynamic> jugadoresMap = {};
      if (sesion['jugadores'] is Map) {
        jugadoresMap = Map<String, dynamic>.from(sesion['jugadores']);
      } else {
        return <UsuarioModel>[];
      }

      final maxJugadores = (sesion['maxJugadores'] is int)
          ? sesion['maxJugadores'] as int
          : int.tryParse(sesion['maxJugadores']?.toString() ?? '') ?? 4;

      // Obtener ronda actual para buscar las manos
      final rondaActual =
          (sesion['rondas'] != null && sesion['rondas']['actual'] != null)
          ? sesion['rondas']['actual']
          : null;

      List<UsuarioModel> lista = [];

      for (var i = 1; i <= maxJugadores; i++) {
        final clave = 'jugador $i';
        if (!jugadoresMap.containsKey(clave)) continue;

        final v = jugadoresMap[clave];
        if (v == null) continue;

        // Buscar mano en rondas/x/jugador i
        List<dynamic>? manoRaw;
        if (rondaActual != null &&
            sesion['rondas'] != null &&
            sesion['rondas'][rondaActual.toString()] != null) {
          final rondaData = sesion['rondas'][rondaActual.toString()];
          if (rondaData[clave] != null) {
            manoRaw = rondaData[clave];
          }
        }

        if (v is String) {
          lista.add(
            UsuarioModel(
              uid: '',
              email: '',
              nombreUsuario: v,
              avatar: 1,
              mano: manoRaw,
            ),
          );
        } else if (v is Map) {
          lista.add(
            UsuarioModel(
              uid: v['uid']?.toString() ?? '',
              email: v['email']?.toString() ?? '',
              nombreUsuario: v['name']?.toString() ?? '',
              avatar: (v['avatar'] is int)
                  ? v['avatar'] as int
                  : int.tryParse(v['avatar']?.toString() ?? '') ?? 1,
              mano: manoRaw,
            ),
          );
        }
      }
      return lista;
    });
  }

  /// Obtiene el ID del usuario actual
  String obtenerMiUid() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
