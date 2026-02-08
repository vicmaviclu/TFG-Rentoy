import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/baraja_model.dart';
import '../../../models/carta_model.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/errores.dart';
import '../../../models/sesion_model.dart';
import '../../../models/usuario_model.dart';

/// Controlador para la lógica de la sala de espera.
class ControladorSalaEspera {
  final ServicioRealtime _servicio;
  final FirebaseAuth _auth;

  ControladorSalaEspera({ServicioRealtime? servicio, FirebaseAuth? auth})
    : _servicio = servicio ?? ServicioRealtime(),
      _auth = auth ?? FirebaseAuth.instance;

  // Verifica si el usuario actual es el anfitrión
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
          jugadores[i - 1] = UsuarioModel(
            uid: '',
            email: '',
            nombreUsuario: v,
            avatar: 1,
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

  // Intenta ocupar un hueco específico en la sala
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

  // Cancela y elimina la sesión actual
  Future<void> cancelarSesion(String idSesion) async {
    try {
      await _servicio.cancelarSesion(idSesion);
    } catch (e) {
      rethrow;
    }
  }

  // Retira al usuario actual de la sesión
  Future<void> salirDeSesion(String idSesion) async {
    try {
      await _servicio.salirDeSesion(idSesion);
    } catch (e) {
      rethrow;
    }
  }

  // Actualiza el estado de la sesión a 'jugando' e inicializa datos de partida
  Future<void> empezarPartida(
    String idSesion, {
    int puntosObjetivo = 21,
  }) async {
    try {
      // 1. Obtener estado actual de la sesión (para saber jugadores)
      final evento = await _servicio.streamSesion(idSesion).first;
      final val = evento.snapshot.value;
      if (val == null || val is! Map) {
        throw Exception(ErroresPartida.errorSesionInfo);
      }

      final sesion = SesionModel.fromMap(val, idSesion);
      final maxJugadores = sesion.maxJugadores;

      // 2. Preparar baraja
      final baraja = Baraja();
      baraja.barajar();

      // 3. Estructura para las manos
      final manosTemp = <String, List<Carta>>{};

      // Inicializar listas vacías para jugadores presentes
      for (var i = 1; i <= maxJugadores; i++) {
        manosTemp['jugador $i'] = [];
      }

      // 4. Repartir 3 cartas, una a una
      for (var ronda = 0; ronda < 3; ronda++) {
        for (var i = 1; i <= maxJugadores; i++) {
          if (baraja.cartas.isNotEmpty) {
            manosTemp['jugador $i']?.add(baraja.cartas.removeAt(0));
          }
        }
      }

      // 5. Preparar Updates
      final updates = <String, dynamic>{
        'estado': TextoPartida.estadoJugando,
        'rondas/actual': 1,
        'puntos/objetivo': puntosObjetivo,
        'puntos/equipo1': 0,
        'puntos/equipo2': 0,
        'rondas/1/puntos': 1,
      };

      // Añadir manos a la ronda 1
      manosTemp.forEach((key, cartas) {
        updates['rondas/1/$key'] = cartas.map((c) => c.toMap()).toList();
      });

      // 6. Enviar a Servicio
      await _servicio.iniciarPartida(idSesion, updates);
    } catch (e) {
      rethrow;
    }
  }
}
