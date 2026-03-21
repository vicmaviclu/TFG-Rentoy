import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../models/usuario_model.dart';
import '../../../models/carta_model.dart';

import '../../../models/baraja_model.dart';
import '../../../core/constantes/errores.dart';

/// Controlador principal para la lógica de la partida.
class ControladorPartida {
  final ServicioRealtime _servicio;

  ControladorPartida({required ServicioRealtime servicio})
    : _servicio = servicio;

  // --- CONSTANTES PRIVADAS PARA CLAVES FIREBASE ---
  static const String _kKeyRondas = 'rondas';
  static const String _kKeyActual = 'actual';
  static const String _kKeyJugadores = 'jugadores';
  static const String _kKeyMaxJugadores = 'maxJugadores';
  static const String _kKeyCartaGanadora = 'carta_ganadora';
  static const String _kKeyMuestra = 'muestra';
  static const String _kKeyTurno = 'turno';
  static const String _kKeyUid = 'uid';
  static const String _kKeyEmail = 'email';
  static const String _kKeyName = 'name';
  static const String _kKeyAvatar = 'avatar';
  static const String _kKeyUsada = 'usada';
  static const String _kKeyPuntos = 'puntos';
  static const String _kKeyEquipo1 = 'equipo1';
  static const String _kKeyEquipo2 = 'equipo2';

  // --- HELPERS PRIVADOS ---
  int _safeInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _safeString(dynamic value, [String defaultValue = '']) {
    return value?.toString() ?? defaultValue;
  }

  Map<String, dynamic> _safeMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

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
      final jugadoresMap = _safeMap(sesion[_kKeyJugadores]);
      if (jugadoresMap.isEmpty) return <UsuarioModel>[];

      final maxJugadores = _safeInt(sesion[_kKeyMaxJugadores], 4);

      // Obtener ronda actual para buscar las manos
      final rondas = _safeMap(sesion[_kKeyRondas]);
      final rondaActual = rondas[_kKeyActual];
      final rondaData = _safeMap(rondas[rondaActual.toString()]);

      List<UsuarioModel> lista = [];

      for (var i = 1; i <= maxJugadores; i++) {
        final clave = 'jugador $i';
        if (!jugadoresMap.containsKey(clave)) continue;

        final v = jugadoresMap[clave];
        if (v == null) continue;

        // Buscar mano
        List<dynamic>? manoRaw;
        if (rondaData.isNotEmpty && rondaData[clave] != null) {
          manoRaw = rondaData[clave] as List<dynamic>?;
        }

        if (v is String) {
          lista.add(
            UsuarioModel(
              uid: '',
              email: '',
              nombreUsuario: v,
              avatar: 1,
              mano: manoRaw,
              keyJugador: clave,
            ),
          );
        } else if (v is Map) {
          lista.add(
            UsuarioModel(
              uid: _safeString(v[_kKeyUid]),
              email: _safeString(v[_kKeyEmail]),
              nombreUsuario: _safeString(v[_kKeyName]),
              avatar: _safeInt(v[_kKeyAvatar], 1),
              mano: manoRaw,
              keyJugador: clave,
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

  Stream<Map<String, dynamic>> streamCartaGanadora(String idPartida) {
    return _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is! Map) return {};

      final rondas = _safeMap(val[_kKeyRondas]);
      final actual = rondas[_kKeyActual];
      if (actual == null) return {};

      final rondaData = _safeMap(rondas[actual.toString()]);
      return _safeMap(rondaData[_kKeyCartaGanadora]);
    });
  }

  /// Escucha la carta de muestra de la ronda actual
  Stream<Map<String, dynamic>> streamCartaMuestra(String idPartida) {
    return _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is! Map) return {};

      final rondas = _safeMap(val[_kKeyRondas]);
      final actual = rondas[_kKeyActual];
      if (actual == null) return {};

      final rondaData = _safeMap(rondas[actual.toString()]);
      return _safeMap(rondaData[_kKeyMuestra]);
    });
  }

  /// Escucha el estado del envite de la ronda actual
  Stream<Map<String, dynamic>> streamEnvite(String idPartida) {
    return _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is! Map) return {};

      final rondas = _safeMap(val[_kKeyRondas]);
      final actual = rondas[_kKeyActual];
      if (actual == null) return {};

      final rondaData = _safeMap(rondas[actual.toString()]);
      return _safeMap(rondaData['envite']);
    });
  }

  /// Inicia un envite por primera vez en la ronda
  Future<void> cantar(String idPartida) async {
    final miKey = await obtenerMiKeyJugador(idPartida);
    if (miKey == null) return;
    final ronda = await obtenerRondaActual(idPartida);
    if (ronda == null) return;

    // Check session data for maxPlayers to find next
    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    if (val is! Map) return;

    // Server-side validation for double singing
    final rondasInfo = _safeMap(val[_kKeyRondas]);
    final rondaData = _safeMap(rondasInfo[ronda]);

    int miNumero = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 1;
    int equipo = (miNumero % 2 != 0) ? 1 : 2;

    if (rondaData['ultimo_equipo_canto'] == equipo) {
      // El equipo ya cantó, no puede volver a cantar dos veces seguidas
      return;
    }

    final maxPlayers = _safeInt(val[_kKeyMaxJugadores], 4);
    int siguienteNumero = (miNumero % maxPlayers) + 1;
    String siguienteKey = 'jugador $siguienteNumero';

    await _servicio.enviarEnvite(
      sessionId: idPartida,
      rondaId: ronda,
      quienEnvia: miKey,
      quienResponde: siguienteKey,
      equipoEnvia: equipo,
    );
  }

  /// Responde a un envite (aceptar o reenviar subiéndolo)
  Future<void> responderCantar(String idPartida, bool aceptar) async {
    final miKey = await obtenerMiKeyJugador(idPartida);
    if (miKey == null) return;
    final ronda = await obtenerRondaActual(idPartida);
    if (ronda == null) return;

    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    if (val is! Map) return;

    final rondas = _safeMap(val[_kKeyRondas]);
    final rondaData = _safeMap(rondas[ronda]);

    final enviteData = _safeMap(rondaData['envite']);
    if (enviteData.isEmpty || enviteData['estado'] != 'pendiente') return;

    int puntosActuales = _safeInt(rondaData['puntos'], 1);
    int nuevosPuntos = puntosActuales == 1 ? 3 : puntosActuales + 3;

    if (aceptar) {
      // Calcula puntos y envía respuesta
      await _servicio.responderEnvite(
        sessionId: idPartida,
        rondaId: ronda,
        aceptar: true,
        nuevosPuntos: nuevosPuntos,
      );
    } else {
      // Rechaza y reenvia el canto al jugador original
      String quienEnviaOriginal = _safeString(enviteData['quien_envia']);

      int miNumero = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 1;
      int equipo = (miNumero % 2 != 0) ? 1 : 2;

      // Actualiza puntos de la ronda
      await _servicio.responderEnvite(
        sessionId: idPartida,
        rondaId: ronda,
        aceptar: false,
        nuevosPuntos: nuevosPuntos,
      );

      // Envía el nuevo envite de respuesta
      await _servicio.enviarEnvite(
        sessionId: idPartida,
        rondaId: ronda,
        quienEnvia: miKey,
        quienResponde: quienEnviaOriginal,
        equipoEnvia: equipo,
      );
    }
  }

  /// Escucha el turno actual de la partida
  Stream<int> streamTurnoActual(String idPartida) {
    return _servicio.streamSesion(idPartida).map((event) {
      final val = event.snapshot.value;
      if (val is! Map) return 1;

      final rondas = _safeMap(val[_kKeyRondas]);
      final actual = rondas[_kKeyActual];
      if (actual == null) return 1;

      final rondaData = _safeMap(rondas[actual.toString()]);
      return _safeInt(rondaData[_kKeyTurno], 1);
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
    final maxPlayers = _safeInt(sesion[_kKeyMaxJugadores], 4);
    final jugadoresMap = _safeMap(sesion[_kKeyJugadores]);

    for (var i = 1; i <= maxPlayers; i++) {
      final key = 'jugador $i';
      final p = _safeMap(jugadoresMap[key]);
      if (_safeString(p[_kKeyUid]) == uid) {
        return key;
      }
    }
    return null;
  }

  /// Obtiene la ronda actual
  Future<String?> obtenerRondaActual(String idPartida) async {
    final event = await _servicio.streamSesion(idPartida).first;
    final val = event.snapshot.value;
    if (val is! Map) return null;

    final rondas = _safeMap(val[_kKeyRondas]);
    final actual = rondas[_kKeyActual];
    return actual?.toString();
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
      final rondas = _safeMap(val[_kKeyRondas]);
      final actual = rondas[_kKeyActual];
      if (actual != null) {
        ronda = actual.toString();
        final rondaData = _safeMap(rondas[ronda]);

        // Obtener turno actual para validación
        turnoActual = _safeInt(rondaData[_kKeyTurno], 1);

        // Obtener carta de la mano
        if (rondaData[miKey] is List) {
          final mano = rondaData[miKey] as List;
          if (cartaIndex >= 0 && cartaIndex < mano.length) {
            final c = mano[cartaIndex];
            if (c is Map) {
              cartaData = Map<String, dynamic>.from(c);
            }
          }
        }
      }
      maxPlayers = _safeInt(val[_kKeyMaxJugadores], 4);
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

    // Calcular fuerzas y determinar ganador
    // 1. Contar cartas usadas para saber si empiezo baza
    int cartasUsadas = 0;
    if (val is Map) {
      final rondas = _safeMap(val[_kKeyRondas]);
      final rondaDataAux = _safeMap(rondas[ronda]);
      for (var i = 1; i <= maxPlayers; i++) {
        final k = 'jugador $i';
        if (rondaDataAux[k] is List) {
          final mano = rondaDataAux[k] as List;
          for (var c in mano) {
            if (c is Map && c[_kKeyUsada] == true) {
              cartasUsadas++;
            }
          }
        }
      }
    }

    bool inicioBaza = (cartasUsadas % maxPlayers == 0);
    bool finDeBaza = (cartasUsadas % maxPlayers == maxPlayers - 1);

    // 2. Preparar datos para reglas
    final miCarta = Carta.fromMap(cartaData);

    // Datos de la ronda actual
    final rondaDataActual = (val is Map)
        ? _safeMap(_safeMap(val['rondas'])[ronda])
        : {};

    final muestraData = _safeMap(rondaDataActual[_kKeyMuestra]);
    final paloMuestra = _safeString(muestraData['palo']);

    // Obtener palo de salida y carta ganadora actual
    String? paloSalida = _safeString(rondaDataActual['palo_salida']);
    if (paloSalida.isEmpty) paloSalida = null;

    final cartaGanadoraMap = _safeMap(rondaDataActual[_kKeyCartaGanadora]);
    Carta? cartaGanadora;
    if (cartaGanadoraMap.isNotEmpty && cartaGanadoraMap['carta'] != null) {
      cartaGanadora = Carta.fromMap(_safeMap(cartaGanadoraMap['carta']));
    }

    // 3. Lógica de inicio de baza vs continuación
    String? nuevoPaloSalida;

    if (inicioBaza) {
      // Si empiezo baza, ignoro la carta ganadora anterior (visual)
      // y establezco mi palo como salida.
      cartaGanadora = null;
      paloSalida = miCarta.palo;
      nuevoPaloSalida = miCarta.palo;
    } else {
      // Si no hay palo salida registrado, asumimos el de la carta ganadora
      if (paloSalida == null && cartaGanadora != null) {
        paloSalida = cartaGanadora.palo;
        nuevoPaloSalida = paloSalida;
      }

      // LÓGICA DE ARRASTRE
      if (paloSalida == paloMuestra && miCarta.palo != paloMuestra) {
        bool tieneMuestra = false;
        if (rondaDataActual[miKey] is List) {
          final mano = rondaDataActual[miKey] as List;
          for (var c in mano) {
            if (c is Map && c[_kKeyUsada] != true && c['palo'] == paloMuestra) {
              tieneMuestra = true;
              break;
            }
          }
        }
        if (tieneMuestra) {
          throw Exception(ErroresPartida.arrastreObligatorio);
        }
      }
    }

    // 4. Calcular ganador usando la lógica de Baraja (Eager Calculation)
    bool yoGano = false;
    if (cartaGanadora == null) {
      yoGano = true;
    } else {
      // Creamos una lista temporal con las dos cartas en disputa para calcular sus valores
      // en este contexto específico.
      final cartasDisputa = [miCarta, cartaGanadora];

      // Leer reglas personalizadas si existen
      Map<String, int>? reglasPersonalizadas;
      if (val is Map && val['reglas_personalizadas'] is Map) {
        reglasPersonalizadas = Map<String, int>.from(
          val['reglas_personalizadas'],
        );
      }

      Baraja.calcularValores(
        cartasDisputa,
        paloMuestra,
        paloSalida,
        maxPlayers,
        reglasPersonalizadas,
      );

      if (miCarta.valor > cartaGanadora.valor) {
        yoGano = true;
      }
    }

    Map<String, dynamic>? datosNuevoGanador;
    if (yoGano) {
      // Determinar equipo
      int numJugador = int.tryParse(miKey.replaceAll('jugador ', '')) ?? 0;
      int equipo = (numJugador % 2 != 0) ? 1 : 2; // Impares eq 1, Pares eq 2

      datosNuevoGanador = {
        'carta': cartaData,
        'jugador': miKey,
        'equipo': equipo,
      };
    }

    String? ganadorBazaKey;
    int? numBaza;
    if (finDeBaza) {
      if (yoGano) {
        ganadorBazaKey = miKey;
        proximoTurno =
            int.tryParse(miKey.replaceAll('jugador ', '')) ?? proximoTurno;
      } else if (cartaGanadoraMap.isNotEmpty &&
          cartaGanadoraMap['jugador'] != null) {
        ganadorBazaKey = cartaGanadoraMap['jugador'].toString();
        proximoTurno =
            int.tryParse(ganadorBazaKey.replaceAll('jugador ', '')) ??
            proximoTurno;
      } else {
        ganadorBazaKey = miKey;
      }
      numBaza = (cartasUsadas ~/ maxPlayers) + 1;
    }

    await _servicio.jugarCarta(
      sessionId: idPartida,
      rondaId: ronda,
      jugadorKey: miKey,
      cartaIndex: cartaIndex,
      cartaData: cartaData,
      nuevoTurno: proximoTurno,
      cartaGanadoraData: datosNuevoGanador,
      paloSalida: nuevoPaloSalida,
      ganadorBazaKey: ganadorBazaKey,
      numBaza: numBaza,
    );

    // --- LÓGICA DE FIN DE RONDA ---
    // Obtener snapshot reciente para verificar cartas jugadas
    final snapPost = await _servicio.streamSesion(idPartida).first;
    final valPost = snapPost.snapshot.value;
    if (valPost is! Map) return;

    final rondasPost = _safeMap(valPost[_kKeyRondas]);
    final rondaData = _safeMap(rondasPost[ronda]);
    if (rondaData.isEmpty) return;

    int cartasJugadas = 0;
    for (var i = 1; i <= maxPlayers; i++) {
      final k = 'jugador $i';
      if (rondaData[k] is List) {
        final mano = rondaData[k] as List;
        for (var c in mano) {
          if (c is Map && c[_kKeyUsada] == true) {
            cartasJugadas++;
          }
        }
      }
    }

    final totalCartas = maxPlayers * 3;
    if (cartasJugadas >= totalCartas) {
      // FIN DE RONDA
      // 1. Obtener carta ganadora de la última baza
      final cg = _safeMap(rondaData[_kKeyCartaGanadora]);
      int equipoGanador = 0;
      if (cg.isNotEmpty && cg['equipo'] is int) {
        equipoGanador = cg['equipo'];
      }

      // 2. Calcular puntos
      int puntosRonda = _safeInt(rondaData[_kKeyPuntos], 1);

      // Leemos puntos globales
      final puntosGlobales = _safeMap(valPost[_kKeyPuntos]);
      int p1 = _safeInt(puntosGlobales[_kKeyEquipo1]);
      int p2 = _safeInt(puntosGlobales[_kKeyEquipo2]);

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
          nuevosPuntos: {_kKeyEquipo1: p1, _kKeyEquipo2: p2},
        );
      } else {
        // 3. Iniciar siguiente ronda
        final proxRonda = int.parse(ronda) + 1;
        int turnoInicialProxRonda = ((proxRonda - 1) % maxPlayers) + 1;

        await _servicio.iniciarSiguienteRonda(
          sessionId: idPartida,
          proximaRonda: proxRonda,
          maxJugadores: maxPlayers,
          nuevosPuntos: {_kKeyEquipo1: p1, _kKeyEquipo2: p2},
          turnoInicial: turnoInicialProxRonda,
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

  /// Extrae el turno actual de los datos de la partida
  int obtenerTurnoActual(Map datosPartida) {
    if (datosPartida['rondas'] is Map) {
      final rondas = datosPartida['rondas'];
      final actual = rondas['actual'];
      if (actual != null && rondas[actual.toString()] is Map) {
        return rondas[actual.toString()]['turno'] ?? 1;
      }
    }
    return 1;
  }

  /// Extrae las bazas ganadas por cada equipo en la ronda actual
  Map<String, int> obtenerBazasGanadas(Map datosPartida) {
    int bazasEq1 = 0;
    int bazasEq2 = 0;

    if (datosPartida['rondas'] is Map) {
      final rondas = datosPartida['rondas'];
      final actual = rondas['actual'];
      if (actual != null && rondas[actual.toString()] is Map) {
        final rondaActualData = rondas[actual.toString()];

        if (rondaActualData['bazas_ganadas'] is Map) {
          final bazas = rondaActualData['bazas_ganadas'] as Map;
          bazas.forEach((key, ganadorKey) {
            String ganadorStr = ganadorKey.toString();
            int numJugador =
                int.tryParse(ganadorStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            int equipo = (numJugador % 2 != 0)
                ? 1
                : 2; // Impares eq 1, Pares eq 2

            if (equipo == 1) {
              bazasEq1++;
            } else {
              bazasEq2++;
            }
          });
        }
      }
    }
    return {'equipo1': bazasEq1, 'equipo2': bazasEq2};
  }

  /// Método para saber si es el turno de un jugador usando su keyJugador (ej: 'jugador 1')
  bool esTurnoDeJugador(UsuarioModel usuario, int turnoActual) {
    if (usuario.keyJugador == null) return false;
    int? numeroJugador = int.tryParse(
      usuario.keyJugador!.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (numeroJugador != null) {
      return numeroJugador == turnoActual;
    }
    return false;
  }
}
