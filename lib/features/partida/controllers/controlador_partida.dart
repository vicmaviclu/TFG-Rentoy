import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/usuario_model.dart';
import '../../../core/constantes/errores.dart';

/// Controlador principal para la lógica de la partida.
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

  /// Escucha el turno actual de la partida
  Stream<int> streamTurnoActual(String idPartida) {
    return _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is Map &&
          val['rondas'] != null &&
          val['rondas']['actual'] != null) {
        final r = val['rondas']['actual'].toString();
        if (val['rondas'][r] != null && val['rondas'][r]['turno'] != null) {
          final t = val['rondas'][r]['turno'];
          return (t is int) ? t : int.tryParse(t.toString()) ?? 1;
        }
      }
      return 1; // Por defecto
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

  /// Juega una carta en la partida actual.
  Future<void> jugarCarta(String idPartida, int cartaIndex) async {
    // Obtener mi key (jugador 1, etc)
    final miKey = await obtenerMiKeyJugador(idPartida);
    if (miKey == null) throw Exception(ErroresPartida.jugadorNoEncontrado);

    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    String? ronda;
    int maxPlayers = 4;
    int turnoActual = 1;
    Map<String, dynamic>? cartaData;

    if (val is Map) {
      if (val['rondas'] != null && val['rondas']['actual'] != null) {
        ronda = val['rondas']['actual'].toString();
        // Obtener turno actual para validación
        if (val['rondas'][ronda] != null &&
            val['rondas'][ronda]['turno'] != null) {
          turnoActual = (val['rondas'][ronda]['turno'] is int)
              ? val['rondas'][ronda]['turno']
              : int.tryParse(val['rondas'][ronda]['turno'].toString()) ?? 1;
        }

        // Obtener carta de la mano
        if (val['rondas'][ronda] != null) {
          final rondaObj = val['rondas'][ronda];
          if (rondaObj[miKey] is List) {
            final mano = rondaObj[miKey] as List;
            if (cartaIndex >= 0 && cartaIndex < mano.length) {
              final c = mano[cartaIndex];
              if (c is Map) {
                cartaData = Map<String, dynamic>.from(c);
              }
            }
          }
        }
      }
      if (val['maxJugadores'] != null) {
        maxPlayers = (val['maxJugadores'] is int)
            ? val['maxJugadores']
            : int.tryParse(val['maxJugadores'].toString()) ?? 4;
      }
    }

    if (ronda == null) throw Exception(ErroresPartida.rondaNoActiva);
    if (cartaData == null) throw Exception(ErroresPartida.cartaNoValida);

    // Verificar si es mi turno
    final miNumero = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 0;
    if (miNumero != turnoActual) {
      // throw Exception(TextoPartida.errorNoEsTuTurno);
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

    // --- LÓGICA DE FIN DE RONDA ---
    // Obtener snapshot reciente para verificar cartas jugadas
    final snapPost = await _servicio.streamSesion(idPartida).first;
    final valPost = snapPost.snapshot.value;
    if (valPost is! Map) return;

    final rondaData = valPost['rondas']?[ronda];
    if (rondaData == null) return;

    int cartasJugadas = 0;
    for (var i = 1; i <= maxPlayers; i++) {
      final k = 'jugador $i';
      if (rondaData[k] is List) {
        final mano = rondaData[k] as List;
        for (var c in mano) {
          if (c is Map && c['usada'] == true) {
            cartasJugadas++;
          }
        }
      }
    }

    final totalCartas = maxPlayers * 3;
    if (cartasJugadas >= totalCartas) {
      // FIN DE RONDA
      // 1. Obtener carta ganadora de la última baza (ya grabada en jugarCarta)
      final cg = rondaData['carta_ganadora'];
      int equipoGanador = 0;
      if (cg is Map && cg['equipo'] is int) {
        equipoGanador = cg['equipo'];
      }

      // 2. Calcular puntos (ej. 1 punto por ganar la ronda)
      // Ojo: Aquí deberíamos sumar puntaje real de las cartas, pero por ahora simplificado.
      // Leemos puntos actuales de la ronda
      int puntosRonda = 1;
      if (rondaData['puntos'] is int) {
        puntosRonda = rondaData['puntos'];
      }

      // Leemos puntos globales
      final puntosGlobales = valPost['puntos'];
      int p1 = 0;
      int p2 = 0;
      if (puntosGlobales is Map) {
        p1 = (puntosGlobales['equipo1'] is int) ? puntosGlobales['equipo1'] : 0;
        p2 = (puntosGlobales['equipo2'] is int) ? puntosGlobales['equipo2'] : 0;
      }

      if (equipoGanador == 1) {
        p1 += puntosRonda;
      } else if (equipoGanador == 2) {
        p2 += puntosRonda;
      }

      // Comprobar si hay ganador
      bool hayGanador = false;
      int winner = 0;

      if (p1 >= 21 || p2 >= 21) {
        if (p1 > p2) {
          winner = 1;
          hayGanador = true;
        } else if (p2 > p1) {
          winner = 2;
          hayGanador = true;
        }
      }

      if (hayGanador) {
        await _servicio.finalizarPartida(
          sessionId: idPartida,
          equipoGanador: winner,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
        );
      } else {
        // 3. Iniciar siguiente ronda
        final proxRonda = int.parse(ronda) + 1;
        await _servicio.iniciarSiguienteRonda(
          sessionId: idPartida,
          proximaRonda: proxRonda,
          maxJugadores: maxPlayers,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
        );
      }
    }
  }

  /// Organiza a los jugadores en dos equipos: rivales (arriba) y mi equipo (abajo).
  /// Retorna un mapa con claves 'arriba' y 'abajo'.
  Map<String, List<UsuarioModel>> organizarEquipos(
    List<UsuarioModel> jugadores,
    String miUid,
  ) {
    List<UsuarioModel> equipo1 = [];
    List<UsuarioModel> equipo2 = [];
    int miIndice = -1;

    for (int i = 0; i < jugadores.length; i++) {
      if (jugadores[i].uid == miUid) {
        miIndice = i;
      }
      // Lógica par/impar para equipos
      if (i % 2 == 0) {
        equipo1.add(jugadores[i]);
      } else {
        equipo2.add(jugadores[i]);
      }
    }

    // Determinar qué equipo va abajo (mi equipo)
    bool soyEquipo1 = (miIndice != -1 && miIndice % 2 == 0);

    // Si no me encuentro (espectador o error), defecto Equipo 1 abajo
    return {
      'abajo': soyEquipo1 ? equipo1 : equipo2,
      'arriba': soyEquipo1 ? equipo2 : equipo1,
    };
  }

  /// Determina si el usuario pertenece al Equipo 1 (índices pares).
  bool soyEquipo1(List<UsuarioModel> jugadores, String miUid) {
    for (int i = 0; i < jugadores.length; i++) {
      if (jugadores[i].uid == miUid) {
        return i % 2 == 0;
      }
    }
    return false;
  }

  /// Comprueba si es el turno del jugador especificado por su key (ej: "jugador 1")
  bool esMiTurno(String? miKey, int turnoActual) {
    if (miKey == null) return false;
    final miNumero = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 0;
    return miNumero == turnoActual;
  }
}
