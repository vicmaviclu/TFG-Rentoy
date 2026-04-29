import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/carta_model.dart';
import '../../../models/baraja_model.dart';

class ControladorBot {
  final String sessionId;
  final ServicioRealtime _servicio;
  final String botKey =
      'jugador 2'; // El bot siempre será jugador 2 en práctica
  final int botEquipo = 2;

  StreamSubscription<DatabaseEvent>? _subscripcion;
  bool _pensando = false;

  ControladorBot({required this.sessionId, required ServicioRealtime servicio})
    : _servicio = servicio;

  Map<String, dynamic>? _ultimoEstado;

  void iniciar() {
    _subscripcion = _servicio.streamSesion(sessionId).listen((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        _ultimoEstado = Map<String, dynamic>.from(event.snapshot.value as Map);
        _evaluarEstado(_ultimoEstado!);
      }
    });
  }

  void detener() {
    _subscripcion?.cancel();
  }

  Future<void> _evaluarEstado(Map<String, dynamic> datosPartida) async {
    if (_pensando) return;

    final estado = datosPartida['estado'];
    if (estado != 'jugando') return;

    final rondas = datosPartida['rondas'];
    if (rondas is! Map) return;

    final actual = rondas['actual'];
    if (actual == null) return;

    final rondaId = actual.toString();
    final rondaData = rondas[rondaId];
    if (rondaData is! Map) return;

    // Comprobar envite pendiente
    final enviteData = rondaData['envite'];
    if (enviteData is Map && enviteData['estado'] == 'pendiente') {
      if (enviteData['quien_responde'] == botKey) {
        await _responderEnvite(rondaId, rondaData, datosPartida);
        return; // Detenemos aquí, ya que responder podría cambiar el estado de la ronda
      }
    }

    // Comprobar si es mi turno
    final turnoActual = rondaData['turno'];
    if (turnoActual != 2) return; // Si no es turno 2, el bot no tira

    // El bot tiene que jugar una carta
    await _jugarCarta(rondaId, rondaData, datosPartida);
  }

  Future<void> _responderEnvite(
    String rondaId,
    Map rondaData,
    Map datosPartida,
  ) async {
    _pensando = true;
    await Future.delayed(const Duration(seconds: 2));

    bool acepta = true;

    final miMano = rondaData[botKey];
    final muestra = rondaData['muestra'];

    // Contar cartas buenas
    int cartasBuenas = 0;
    if (miMano is List && muestra is Map) {
      final paloMuestra = muestra['palo'];
      for (var c in miMano) {
        if (c is Map && c['usada'] != true) {
          if (c['palo'] == paloMuestra) cartasBuenas++;
          if (c['palo'] == 'Oros' &&
              (c['numero'] == 11 || c['numero'] == 10 || c['numero'] == 5)) {
            cartasBuenas++;
          }
        }
      }
    }

    if (cartasBuenas == 0) acepta = false; // Si no tiene nada bueno, rechaza
    // Si tiene 1, acepta (no reenvia).

    int puntosActuales = rondaData['puntos'] ?? 1;
    int nuevosPuntos = puntosActuales == 1 ? 3 : puntosActuales + 3;

    if (acepta) {
      await _servicio.responderEnvite(
        sessionId: sessionId,
        rondaId: rondaId,
        aceptar: true,
        nuevosPuntos: nuevosPuntos,
      );
    } else {
      // Rechazar definitivamente dando puntos al rival y avanzando
      final int maxPlayers = 2;
      final puntosGlobales = datosPartida['puntos'] ?? {};
      int p1 = puntosGlobales['equipo1'] ?? 0;
      int p2 = puntosGlobales['equipo2'] ?? 0;

      p1 += puntosActuales;

      bool hayGanador = p1 >= 21 || p2 >= 21;
      int winner = (p1 > p2) ? 1 : 2;

      if (hayGanador) {
        await _servicio.finalizarPartida(
          sessionId: sessionId,
          equipoGanador: winner,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
        );
      } else {
        final proxRonda = int.parse(rondaId) + 1;
        int turnoInicial = ((proxRonda - 1) % maxPlayers) + 1;

        await _servicio.iniciarSiguienteRonda(
          sessionId: sessionId,
          proximaRonda: proxRonda,
          maxJugadores: maxPlayers,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
          turnoInicial: turnoInicial,
        );
      }
    }

    _pensando = false;
    if (_ultimoEstado != null) {
      Future.microtask(() => _evaluarEstado(_ultimoEstado!));
    }
  }

  Future<void> _jugarCarta(
    String rondaId,
    Map rondaData,
    Map datosPartida,
  ) async {
    _pensando = true;
    await Future.delayed(const Duration(milliseconds: 2000));

    final miMano = rondaData[botKey];
    if (miMano is! List) {
      _pensando = false;
      return;
    }

    List<Map<String, dynamic>> cartasDisponibles = [];
    for (int i = 0; i < miMano.length; i++) {
      if (miMano[i] is Map && miMano[i]['usada'] != true) {
        final c = Map<String, dynamic>.from(miMano[i]);
        c['index'] = i;
        cartasDisponibles.add(c);
      }
    }

    if (cartasDisponibles.isEmpty) {
      _pensando = false;
      return;
    }

    // Calcular si inicio baza o respondo
    int cartasUsadasTotal = 0;
    for (var i = 1; i <= 2; i++) {
      final k = 'jugador $i';
      if (rondaData[k] is List) {
        for (var c in rondaData[k]) {
          if (c is Map && c['usada'] == true) cartasUsadasTotal++;
        }
      }
    }

    bool inicioBaza = (cartasUsadasTotal % 2 == 0);
    bool finDeBaza = (cartasUsadasTotal % 2 == 1);

    final muestraData = rondaData['muestra'];
    String? paloMuestra = muestraData is Map ? muestraData['palo'] : null;
    String? paloSalida = rondaData['palo_salida'];
    Map? cartaGanadoraData = rondaData['carta_ganadora'];

    // Arrastre obligatorio
    List<Map<String, dynamic>> cartasPermitidas = [];
    if (!inicioBaza && paloSalida == paloMuestra) {
      for (var c in cartasDisponibles) {
        if (c['palo'] == paloMuestra) cartasPermitidas.add(c);
      }
    }

    if (cartasPermitidas.isEmpty) {
      cartasPermitidas = List.from(cartasDisponibles);
    }

    // Elegir carta
    // Lógica básica: tirar la más fuerte si inicio baza, o tratar de ganar si fin de baza.
    Map<String, dynamic> cartaElegida = cartasPermitidas.first;

    // Mejor lógica
    if (!inicioBaza && cartaGanadoraData != null) {
      Carta cg = Carta.fromMap(
        Map<String, dynamic>.from(cartaGanadoraData['carta']),
      );
      Map<String, dynamic>? cartaGana;

      // Intentamos buscar una carta que gane
      for (var c in cartasPermitidas) {
        Carta cb = Carta.fromMap(c);
        final disputas = [cb, cg];
        Map<String, int>? reglasPersonalizadas;
        if (datosPartida['reglas_personalizadas'] is Map) {
          reglasPersonalizadas = Map<String, int>.from(
            datosPartida['reglas_personalizadas'],
          );
        }
        Baraja.calcularValores(
          disputas,
          paloMuestra ?? '',
          paloSalida,
          2,
          reglasPersonalizadas,
        );

        if (cb.valor > cg.valor) {
          cartaGana = c;
          break;
        }
      }

      if (cartaGana != null) {
        cartaElegida = cartaGana; // Tiro una que gane
      } else {
        // Tiro la de menor valor si no puedo ganar
        cartaElegida =
            cartasPermitidas.first; // Podría calcularse la de menor valor
      }
    } else {
      cartaElegida = cartasPermitidas.last;
    }

    // Aplicar lógica de juego igual que el ControladorPartida
    Carta miCarta = Carta.fromMap(cartaElegida);
    int proximoTurno = 1;

    String? nuevoPaloSalida = paloSalida;
    if (inicioBaza) nuevoPaloSalida = miCarta.palo;

    bool yoGano = false;
    Carta? cg;
    if (!inicioBaza &&
        cartaGanadoraData != null &&
        cartaGanadoraData['carta'] != null) {
      cg = Carta.fromMap(Map<String, dynamic>.from(cartaGanadoraData['carta']));
      final disputa = [miCarta, cg];

      Map<String, int>? reglasPersonalizadas;
      if (datosPartida['reglas_personalizadas'] is Map) {
        reglasPersonalizadas = Map<String, int>.from(
          datosPartida['reglas_personalizadas'],
        );
      }

      Baraja.calcularValores(
        disputa,
        paloMuestra ?? '',
        nuevoPaloSalida,
        2,
        reglasPersonalizadas,
      );
      if (miCarta.valor > cg.valor) yoGano = true;
    } else {
      yoGano = true;
    }

    Map<String, dynamic>? datosNuevoGanador;
    if (yoGano) {
      datosNuevoGanador = {
        'carta': cartaElegida,
        'jugador': botKey,
        'equipo': botEquipo,
      };
    } else if (!inicioBaza && cartaGanadoraData != null) {
      // Si no gano, mantengo la ganadora anterior
      datosNuevoGanador = Map<String, dynamic>.from(cartaGanadoraData);
    }

    String? ganadorBazaKey;
    int? numBaza;
    if (finDeBaza) {
      if (yoGano) {
        ganadorBazaKey = botKey;
        proximoTurno = 2; // Gana bot, su turno
      } else {
        ganadorBazaKey = 'jugador 1'; // Gana el humano
        proximoTurno = 1;
      }
      numBaza = (cartasUsadasTotal ~/ 2) + 1;
    }

    await _servicio.jugarCarta(
      sessionId: sessionId,
      rondaId: rondaId,
      jugadorKey: botKey,
      cartaIndex: cartaElegida['index'],
      cartaData: cartaElegida,
      nuevoTurno: proximoTurno,
      cartaGanadoraData: datosNuevoGanador,
      paloSalida: nuevoPaloSalida,
      ganadorBazaKey: ganadorBazaKey,
      numBaza: numBaza,
    );

    // LÓGICA DE FIN DE RONDA
    final snapPost = await _servicio.streamSesion(sessionId).first;
    final valPost = snapPost.snapshot.value;
    if (valPost is! Map) {
      _pensando = false;
      return;
    }

    _ultimoEstado = Map<String, dynamic>.from(valPost);

    final rondasPost = valPost['rondas'];
    if (rondasPost is! Map) {
      _pensando = false;
      return;
    }
    final rData = rondasPost[rondaId];
    if (rData is! Map) {
      _pensando = false;
      return;
    }

    int cartasJugadas = 0;
    for (var i = 1; i <= 2; i++) {
      final k = 'jugador $i';
      if (rData[k] is List) {
        for (var c in rData[k]) {
          if (c is Map && c['usada'] == true) cartasJugadas++;
        }
      }
    }

    bool finDeRonda = cartasJugadas >= 6;
    int? equipoGanador;

    // Comprobar victorias de bazas
    final bazasGanadasMap = rData['bazas_ganadas'] is Map
        ? rData['bazas_ganadas'] as Map
        : {};
    int eq1Bazas = 0;
    int eq2Bazas = 0;

    for (var key in bazasGanadasMap.keys) {
      String winnerKey = bazasGanadasMap[key].toString();
      int numJugador = int.tryParse(winnerKey.replaceAll('jugador ', '')) ?? 0;
      int equipo = (numJugador % 2 != 0) ? 1 : 2;
      if (equipo == 1) {
        eq1Bazas++;
      } else if (equipo == 2) {
        eq2Bazas++;
      }
    }

    if (eq1Bazas >= 2) {
      finDeRonda = true;
      equipoGanador = 1;
    } else if (eq2Bazas >= 2) {
      finDeRonda = true;
      equipoGanador = 2;
    }

    if (finDeRonda) {
      // 2 jug * 3 cartas o 2 bazas ganadas
      if (equipoGanador == null) {
        final cgFinal = rData['carta_ganadora'];
        if (cgFinal is Map && cgFinal['equipo'] is int) {
          equipoGanador = cgFinal['equipo'];
        } else {
          equipoGanador = 0;
        }
      }

      int puntosRonda = rData['puntos'] ?? 1;
      final puntosGlobales = valPost['puntos'] ?? {};
      int p1 = puntosGlobales['equipo1'] ?? 0;
      int p2 = puntosGlobales['equipo2'] ?? 0;

      if (equipoGanador == 1) {
        p1 += puntosRonda;
      } else if (equipoGanador == 2) {
        p2 += puntosRonda;
      }

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
          sessionId: sessionId,
          equipoGanador: winner,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
        );
      } else {
        final proxRonda = int.parse(rondaId) + 1;
        int turnoInicialProxRonda = ((proxRonda - 1) % 2) + 1;

        await _servicio.iniciarSiguienteRonda(
          sessionId: sessionId,
          proximaRonda: proxRonda,
          maxJugadores: 2,
          nuevosPuntos: {'equipo1': p1, 'equipo2': p2},
          turnoInicial: turnoInicialProxRonda,
        );
      }
    }

    _pensando = false;
    if (_ultimoEstado != null) {
      Future.microtask(() => _evaluarEstado(_ultimoEstado!));
    }
  }
}
