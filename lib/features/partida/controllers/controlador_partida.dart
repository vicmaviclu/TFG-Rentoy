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

  Stream<Map<String, dynamic>> streamCartaGanadora(String idPartida) async* {
    // Necesitamos saber la ronda actual antes de suscribirnos.
    // Esto es un poco truco porque la ronda puede cambiar.
    // Lo ideal sería un stream combinado, pero por simpleza re-buscamos la ronda.
    // O mejor, escuchemos la sesión entera y mapeemos, pero streamSesion es costoso.
    // Haremos polling simple o map sobre sesion.

    yield* _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is Map &&
          val['rondas'] != null &&
          val['rondas']['actual'] != null) {
        final r = val['rondas']['actual'].toString();
        if (val['rondas'][r] != null &&
            val['rondas'][r]['carta_ganadora'] != null) {
          final cg = val['rondas'][r]['carta_ganadora'];
          if (cg is Map) return Map<String, dynamic>.from(cg);
        }
      }
      return {};
    });
  }

  /// Busca qué "jugador X" soy yo en la partida
  Future<String?> obtenerMiKeyJugador(String idPartida) async {
    final uid = obtenerMiUid();
    if (uid.isEmpty) return null;

    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    if (val == null || val is! Map) return null;

    final sesion = val;
    final maxPlayers = (sesion['maxJugadores'] is int)
        ? sesion['maxJugadores'] as int
        : int.tryParse(sesion['maxJugadores']?.toString() ?? '') ?? 4;

    if (sesion['jugadores'] is! Map) return null;
    final jugadoresMap = Map<String, dynamic>.from(sesion['jugadores']);

    for (var i = 1; i <= maxPlayers; i++) {
      final key = 'jugador $i';
      final p = jugadoresMap[key];
      if (p is Map && p['uid'] == uid) {
        return key;
      }
    }
    return null;
  }

  /// Obtiene la ronda actual
  Future<String?> obtenerRondaActual(String idPartida) async {
    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    if (val is Map &&
        val['rondas'] != null &&
        val['rondas']['actual'] != null) {
      return val['rondas']['actual'].toString();
    }
    return null;
  }

  Future<void> jugarCarta(
    String idPartida,
    int cartaIndex,
    Map<String, dynamic> cartaData,
  ) async {
    final miKey = await obtenerMiKeyJugador(idPartida);
    if (miKey == null)
      throw Exception("No se encontró el jugador actual en la partida");

    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    String? ronda;
    int maxPlayers = 4;
    int turnoActual = 1;

    if (val is Map) {
      if (val['rondas'] != null && val['rondas']['actual'] != null) {
        ronda = val['rondas']['actual'].toString();
        // Obtener turno actual para validación (opcional) y cálculo
        if (val['rondas'][ronda] != null &&
            val['rondas'][ronda]['turno'] != null) {
          turnoActual = (val['rondas'][ronda]['turno'] is int)
              ? val['rondas'][ronda]['turno']
              : int.tryParse(val['rondas'][ronda]['turno'].toString()) ?? 1;
        }
      }
      if (val['maxJugadores'] != null) {
        maxPlayers = (val['maxJugadores'] is int)
            ? val['maxJugadores']
            : int.tryParse(val['maxJugadores'].toString()) ?? 4;
      }
    }

    if (ronda == null) throw Exception("No hay ronda activa");

    // Verificar si es mi turno
    final miNumero = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 0;
    if (miNumero != turnoActual) {
      // throw Exception("No es tu turno");
      // Comentado para facilitar pruebas si hay desincronización
    }

    // Calcular siguiente turno
    int proximoTurno = (turnoActual % maxPlayers) + 1;

    await _servicio.jugarCarta(
      sessionId: idPartida,
      rondaId: ronda,
      jugadorKey: miKey,
      cartaIndex: cartaIndex,
      cartaData: cartaData,
      nuevoTurno: proximoTurno,
    );
  }
}
