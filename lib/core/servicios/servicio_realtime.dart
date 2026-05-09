import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/usuario_model.dart';
import '../../models/baraja_model.dart';
import '../../models/carta_model.dart';
import '../constantes/errores.dart';

class ServicioRealtime {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://rentoy-online-default-rtdb.europe-west1.firebasedatabase.app',
  );

  /// Devuelve el nombre de usuario a usar
  Future<String> _nombreUsuario(String? providedName, String uid) async {
    if (providedName != null &&
        providedName.isNotEmpty &&
        !providedName.contains('@')) {
      return providedName;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 5));
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final userModel = UsuarioModel.fromDocument(doc);
          if (userModel.nombreUsuario.isNotEmpty) {
            return userModel.nombreUsuario;
          }
        }
      }
    } catch (_) {}

    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty &&
        !user.displayName!.contains('@')) {
      return user.displayName!;
    }

    return providedName != null && providedName.isNotEmpty
        ? providedName.replaceAll(RegExp(r'@.*'), '')
        : 'Jugador';
  }

  /// Crea una nueva sesión con código numérico de 6 dígitos.
  Future<String> crearSesion({
    required String hostName,
    required int maxPlayers,
    required int avatar,
    Map<String, int>? reglasPersonalizadas,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(ErroresSesion.autenticacionCrearPartida);
    }
    
    // Disparamos la limpieza de basura en segundo plano (sin await para no bloquear)
    limpiarSalasAntiguas();
    final rnd = Random.secure();
    
    String pin = '';
    bool pinUnico = false;
    
    // Bucle para asegurar que el PIN no está en uso
    while (!pinUnico) {
      pin = (rnd.nextInt(900000) + 100000).toString();
      final snapshot = await _db
          .ref('sessions')
          .orderByChild('pin')
          .equalTo(pin)
          .limitToFirst(1)
          .get();
          
      if (!snapshot.exists || snapshot.children.isEmpty) {
        pinUnico = true;
      }
    }

    final ref = _db.ref().child('sessions').push();
    final sessionId = ref.key ?? '';
    final now = DateTime.now().toIso8601String();

    final hostDisplay = hostName.isEmpty ? 'Jugador' : hostName;

    final sessionData = {
      'pin': pin,
      'anfitrion': hostDisplay,
      'maxJugadores': maxPlayers,
      'estado': 'esperando',
      'creadoEn': now,
      if (reglasPersonalizadas != null && reglasPersonalizadas.isNotEmpty)
        'reglas_personalizadas': reglasPersonalizadas,
      'jugadores': {
        'jugador 1': {'name': hostDisplay, 'avatar': avatar, 'uid': user.uid},
      },
    };

    try {
      await ref.set(sessionData);

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('partidas').doc(sessionId).set({
        'pin': pin,
        'jugadores': [hostDisplay],
        'estado': 'esperando',
        'maxJugadores': maxPlayers,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      // Añadir al historial del usuario anfitrión
      await firestore.collection('usuarios').doc(user.uid).set({
        'partidas_historial': FieldValue.arrayUnion([sessionId]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error creando sesión: $e");
      rethrow; // Re-lanzar para que el controlador lo sepa
    }

    return sessionId;
  }

  /// Sale de la sesión: elimina la entrada del jugador que coincide con el uid actual
  /// y actualiza el documento de Firestore eliminando el nombre del array `jugadores`.
  Future<void> salirDeSesion(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(ErroresSesion.autenticacionRequerida);
    }
    final ref = referenciaSesion(sessionId);
    final snap = await ref.get();
    if (!snap.exists) {
      return;
    }

    final data = snap.value as dynamic;
    Map<String, dynamic> players = {};
    try {
      if (data is Map && data['jugadores'] != null) {
        players = Map<String, dynamic>.from(data['jugadores']);
      }
    } catch (_) {
      players = {};
    }

    String? removedName;
    for (var i = 1; i <= (data['maxJugadores'] ?? 4); i++) {
      final key = 'jugador $i';
      final val = players.containsKey(key) ? players[key] : null;
      if (val is Map && val['uid'] != null && val['uid'] == user.uid) {
        removedName = val['name']?.toString();
        await ref.child('jugadores/$key').remove();
        break;
      } else if (val is String) {
        final resolved = await _nombreUsuario(null, user.uid);
        if (val == resolved) {
          removedName = val.toString();
          await ref.child('jugadores/$key').remove();
          break;
        }
      }
    }

    if (removedName != null) {
      final firestore = FirebaseFirestore.instance;
      final partidaDoc = firestore.collection('partidas').doc(sessionId);
      final partidaSnap = await partidaDoc.get();
      if (partidaSnap.exists) {
        await partidaDoc.update({
          'jugadores': FieldValue.arrayRemove([removedName]),
        });
      }
    }
  }

  DatabaseReference referenciaSesion(String sessionId) =>
      _db.ref('sessions/$sessionId');

  Stream<DatabaseEvent> streamSesion(String sessionId) =>
      referenciaSesion(sessionId).onValue;

  /// Elimina la sesión tanto en Realtime como en Firestore (usado por el anfitrión)
  Future<void> cancelarSesion(String sessionId) async {
    // eliminar Realtime
    await referenciaSesion(sessionId).remove();
    // eliminar Firestore
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();
    if (partidaSnap.exists) {
      await partidaDoc.delete();
    }
  }

  /// Une a la sesión buscando el siguiente slot libre (jugador2..jugadorN)
  Future<void> unirASesion(String sessionId, String playerName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(ErroresSesion.autenticacionUnirsePartida);
    }
    final ref = referenciaSesion(sessionId);

    // Obtenemos el número máximo de jugadores primero
    final maxPlayersSnap = await ref.child('maxJugadores').get();
    if (!maxPlayersSnap.exists) {
      throw Exception(ErroresSesion.sesionNoEncontrada);
    }
    final maxPlayers = (maxPlayersSnap.value as int?) ?? 2;

    int avatarIndex = 1;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final userModel = UsuarioModel.fromDocument(userDoc);
        avatarIndex = userModel.avatar;
      }
    } catch (_) {}

    final resolvedName = await _nombreUsuario(playerName, user.uid);

    // Usamos una transacción para evitar condiciones de carrera si dos entran a la vez
    final TransactionResult
    transactionResult = await ref.child('jugadores').runTransaction((
      Object? jugadoresData,
    ) {
      final Map<String, dynamic> players = {};

      if (jugadoresData is Map) {
        jugadoresData.forEach((key, value) {
          players[key.toString()] = value;
        });
      } else if (jugadoresData is List) {
        // Manejar caso donde Firebase devuelve una lista (si los índices son numéricos)
        for (int i = 0; i < jugadoresData.length; i++) {
          if (jugadoresData[i] != null) {
            players['jugador $i'] = jugadoresData[i];
          }
        }
      }

      int slot = 0;
      bool alreadyIn = false;

      for (var i = 1; i <= maxPlayers; i++) {
        final key = 'jugador $i';
        final val = players[key];

        if (val is Map && val['uid'] == user.uid) {
          alreadyIn = true;
          break;
        }

        final bool isSlotEmpty =
            (val == null) ||
            (val is String && val.isEmpty) ||
            (val is Map &&
                (val['uid'] == null || val['uid'].toString().isEmpty));

        if (slot == 0 && isSlotEmpty) {
          slot = i;
        }
      }

      if (alreadyIn) {
        return Transaction.abort();
      }

      if (slot == 0) {
        return Transaction.abort();
      }

      final playerKey = 'jugador $slot';
      players[playerKey] = {
        'name': resolvedName,
        'avatar': avatarIndex,
        'uid': user.uid,
      };

      return Transaction.success(players);
    });

    if (!transactionResult.committed) {
      // Verificamos si se canceló porque ya estaba en la sala o porque estaba llena
      final currentJugadores = await ref.child('jugadores').get();
      final jData = currentJugadores.value as Map?;
      bool isIn = false;
      if (jData != null) {
        jData.forEach((k, v) {
          if (v is Map && v['uid'] == user.uid) isIn = true;
        });
      }
      if (isIn) {
        return;
      }
      throw Exception(ErroresSesion.salaLlena);
    }

    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();
    if (partidaSnap.exists) {
      await partidaDoc.update({
        'jugadores': FieldValue.arrayUnion([resolvedName]),
      });
      
      // Añadir al historial del usuario que se une
      await firestore.collection('usuarios').doc(user.uid).set({
        'partidas_historial': FieldValue.arrayUnion([sessionId]),
      }, SetOptions(merge: true));
    }
  }

  /// Toma un hueco específico en la sesión (cambia de slot si ya estabas en otro).
  Future<void> tomarHueco(String sessionId, int slot) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(ErroresSesion.autenticacionRequerida);
    }
    final ref = referenciaSesion(sessionId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw Exception(ErroresSesion.sesionNoEncontrada);
    }

    final data = snap.value as dynamic;
    final maxPlayers = (data is Map && data['maxJugadores'] is int)
        ? data['maxJugadores'] as int
        : (data['maxJugadores'] as int?) ?? 2;

    Map<String, dynamic> players = {};
    try {
      if (data is Map && data['jugadores'] != null) {
        players = Map<String, dynamic>.from(data['jugadores']);
      }
    } catch (_) {
      players = {};
    }

    final resolvedName = await _nombreUsuario(null, user.uid);

    int avatarIndex = 1;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final userModel = UsuarioModel.fromDocument(userDoc);
        avatarIndex = userModel.avatar;
      }
    } catch (_) {}

    final targetKey = 'jugador $slot';
    final targetVal = players.containsKey(targetKey)
        ? players[targetKey]
        : null;

    if (targetVal != null) {
      if (targetVal is Map && targetVal['uid'] != null) {
        throw Exception(ErroresSesion.huecoOcupado);
      } else if (targetVal is String && targetVal.isNotEmpty) {
        throw Exception(ErroresSesion.huecoOcupado);
      }
    }

    for (var i = 1; i <= maxPlayers; i++) {
      final key = 'jugador $i';
      final val = players.containsKey(key) ? players[key] : null;
      if (val is Map && val['uid'] != null && val['uid'] == user.uid) {
        await ref.child('jugadores/$key').remove();
      } else if (val is String && val == resolvedName) {
        await ref.child('jugadores/$key').remove();
      }
    }

    await ref.child('jugadores/$targetKey').set({
      'name': resolvedName,
      'avatar': avatarIndex,
      'uid': user.uid,
    });
  }

  /// Busca una sesión por su PIN y devuelve un Map con {id, anfitrion, maxJugadores}.
  /// Lanza excepción si no existe.
  Future<Map<String, dynamic>> buscarSesionPorPin(String pin) async {
    final snapshot = await _db
        .ref('sessions')
        .orderByChild('pin')
        .equalTo(pin)
        .limitToFirst(1)
        .get();

    if (!snapshot.exists || snapshot.children.isEmpty) {
      throw Exception(ErroresSesion.pinNoEncontrado);
    }

    final snap = snapshot.children.first;
    final val = snap.value as Map?;
    final id = snap.key!;
    final anfitrion = val?['anfitrion']?.toString() ?? 'Anfitrión';
    final maxJugadores = (val?['maxJugadores'] as int?) ?? 2;

    return {'id': id, 'anfitrion': anfitrion, 'maxJugadores': maxJugadores};
  }

  /// Actualiza el estado de la sesión (ej. 'jugando', 'finalizada')
  Future<void> actualizarEstadoSesion(
    String sessionId,
    String nuevoEstado,
  ) async {
    await referenciaSesion(sessionId).update({'estado': nuevoEstado});

    // También actualizar en Firestore
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();
    if (partidaSnap.exists) {
      await partidaDoc.update({'estado': nuevoEstado});
    }
  }

  /// Inicia la partida recibiendo el mapa de actualizaciones ya calculado.
  /// (El controlador se encarga de barajar y repartir).
  Future<void> iniciarPartida(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    // 1. Actualizar Realtime Database
    await referenciaSesion(sessionId).update(updates);

    // 2. Actualizar Firestore (Espejo parcial)
    final nuevoEstado = updates['estado'];
    final puntos = updates['puntos'];
    final ronda = updates['rondas/actual'];

    if (nuevoEstado != null) {
      final firestore = FirebaseFirestore.instance;
      final partidaDoc = firestore.collection('partidas').doc(sessionId);
      final partidaSnap = await partidaDoc.get();

      if (partidaSnap.exists) {
        final dataFirestore = <String, dynamic>{'estado': nuevoEstado};
        if (puntos != null) {
          dataFirestore['puntos'] = puntos;
        }
        if (ronda != null) {
          dataFirestore['rondaActual'] = ronda;
        }

        await partidaDoc.update(dataFirestore);
      }
    }
  }

  /// Juega una carta: marca usada, actualiza carta ganadora (si se pasa), pasa turno.
  Future<void> jugarCarta({
    required String sessionId,
    required String rondaId,
    required String jugadorKey,
    required int cartaIndex,
    required Map<String, dynamic> cartaData,
    required int nuevoTurno,
    Map<String, dynamic>?
    cartaGanadoraData, // Opcional: Si es null, no se cambia
    String?
    paloSalida, // Opcional: Si se pasa, se guarda como palo de salida de la baza
    String? ganadorBazaKey,
    int? numBaza,
  }) async {
    final ref = referenciaSesion(sessionId);

    final cardPath = 'rondas/$rondaId/$jugadorKey/$cartaIndex/usada';

    final winningPath = 'rondas/$rondaId/carta_ganadora';

    final turnoPath = 'rondas/$rondaId/turno';

    final updates = <String, dynamic>{cardPath: true, turnoPath: nuevoTurno};

    if (cartaGanadoraData != null) {
      // Guardar info completa de la carta ganadora
      final dataGanadora = {
        'carta': cartaGanadoraData['carta'], // La carta que gana
        'jugador': cartaGanadoraData['jugador'], // El jugador que la tiró
        'equipo': cartaGanadoraData['equipo'],
      };
      updates[winningPath] = dataGanadora;
    }

    if (paloSalida != null) {
      updates['rondas/$rondaId/palo_salida'] = paloSalida;
    }

    if (ganadorBazaKey != null && numBaza != null) {
      updates['rondas/$rondaId/bazas_ganadas/baza$numBaza'] = ganadorBazaKey;
    }

    await ref.update(updates);
  }

  /// Limpia la mesa
  Future<void> limpiarCartaGanadora(String sessionId, String rondaId) async {
    await referenciaSesion(
      sessionId,
    ).child('rondas/$rondaId/carta_ganadora').remove();
  }

  // --- LÓGICA DE ENVITES (CANTAR) ---

  /// Envía o reenvía un envite (canto)
  Future<void> enviarEnvite({
    required String sessionId,
    required String rondaId,
    required String quienEnvia,
    required String quienResponde,
    required int equipoEnvia,
  }) async {
    final ref = referenciaSesion(sessionId);
    final envitePath = 'rondas/$rondaId/envite';
    await ref.update({
      '$envitePath/estado': 'pendiente',
      '$envitePath/quien_envia': quienEnvia,
      '$envitePath/quien_responde': quienResponde,
      'rondas/$rondaId/ultimo_equipo_canto':
          equipoEnvia, // Guardado a nivel de ronda
    });
  }

  /// Responde a un envite (aceptar o rechazar)
  Future<void> responderEnvite({
    required String sessionId,
    required String rondaId,
    required bool aceptar,
    int? nuevosPuntos,
  }) async {
    final ref = referenciaSesion(sessionId);
    final updates = <String, dynamic>{};

    if (aceptar) {
      // Si acepta, se actualizan los puntos de la ronda y se limpia el envite
      updates['rondas/$rondaId/envite'] = null;
      if (nuevosPuntos != null) {
        updates['rondas/$rondaId/puntos'] = nuevosPuntos;
      }
    } else {
      // Reenviar es enviarEnvite, pero puede que queramos actualizar los puntos provisionales
      updates['rondas/$rondaId/envite'] = null;
      if (nuevosPuntos != null) {
        updates['rondas/$rondaId/puntos'] = nuevosPuntos;
      }
    }

    await ref.update(updates);
  }

  /// Escucha el estado del envite de la ronda actual
  Stream<Map<String, dynamic>> streamEnvite(String sessionId, String rondaId) {
    if (rondaId.isEmpty) return Stream.value({});
    return referenciaSesion(
      sessionId,
    ).child('rondas/$rondaId/envite').onValue.map((event) {
      final val = event.snapshot.value;
      if (val != null && val is Map) {
        return Map<String, dynamic>.from(val);
      }
      return {};
    });
  }

  /// Carta ganadora de la ronda actual
  Stream<Map<String, dynamic>> streamCartaGanadora(
    String sessionId,
    String rondaId,
  ) {
    if (rondaId.isEmpty) return Stream.value({});
    return referenciaSesion(
      sessionId,
    ).child('rondas/$rondaId/carta_ganadora').onValue.map((event) {
      final val = event.snapshot.value;
      if (val != null && val is Map) {
        return Map<String, dynamic>.from(val);
      }
      return {};
    });
  }

  /// Inicia la siguiente ronda: reparte cartas y actualiza marcadores
  Future<void> iniciarSiguienteRonda({
    required String sessionId,
    required int proximaRonda,
    required int maxJugadores,
    required Map<String, int> nuevosPuntos, // { 'equipo1': x, 'equipo2': y }
    int turnoInicial = 1,
  }) async {
    // 1. Generar nueva baraja y repartir
    final baraja = Baraja();
    baraja.barajar();

    final manosTemp = <String, List<Carta>>{};
    for (var i = 1; i <= maxJugadores; i++) {
      manosTemp['jugador $i'] = [];
    }

    // Repartir 3 cartas a cada uno
    for (var r = 0; r < 3; r++) {
      for (var i = 1; i <= maxJugadores; i++) {
        if (baraja.cartas.isNotEmpty) {
          manosTemp['jugador $i']?.add(baraja.cartas.removeAt(0));
        }
      }
    }

    // Extraer carta de muestra
    Carta? cartaMuestra;
    if (baraja.cartas.isNotEmpty) {
      cartaMuestra = baraja.cartas.removeAt(0);
    }

    // 2. Preparar updates
    final updates = <String, dynamic>{
      'rondas/actual': proximaRonda,
      'rondas/$proximaRonda/puntos': 1, // Puntos base de la nueva ronda
      'rondas/$proximaRonda/turno': turnoInicial, // Turno inicial calculado
      'rondas/$proximaRonda/ultimo_equipo_canto':
          null, // Reseteo del equipo que cantó
      // Actualizar marcadores globales
      'puntos/equipo1': nuevosPuntos['equipo1'],
      'puntos/equipo2': nuevosPuntos['equipo2'],
    };

    if (cartaMuestra != null) {
      updates['rondas/$proximaRonda/muestra'] = cartaMuestra.toMap();
    }

    // Añadir nuevas manos
    manosTemp.forEach((key, cartas) {
      updates['rondas/$proximaRonda/$key'] = cartas
          .map((c) => c.toMap())
          .toList();
    });

    // 3. Ejecutar actualización atómica
    await referenciaSesion(sessionId).update(updates);

    // 4. Actualizar Firestore
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();

    if (partidaSnap.exists) {
      await partidaDoc.update({
        'rondaActual': proximaRonda,
        'puntos': nuevosPuntos,
      });
    }
  }

  /// Finaliza la partida estableciendo el ganador y los puntos finales
  Future<void> finalizarPartida({
    required String sessionId,
    required int equipoGanador,
    required Map<String, int> nuevosPuntos,
  }) async {
    final updates = <String, dynamic>{
      'estado': 'finalizada',
      'ganador': equipoGanador,
      'puntos': nuevosPuntos,
    };

    // 1. Actualizar Realtime
    await referenciaSesion(sessionId).update(updates);

    // 2. Actualizar Firestore
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();

    if (partidaSnap.exists) {
      await partidaDoc.update(updates);
    }
  }

  /// Limpia sesiones antiguas (más de 2 horas) desde el propio cliente.
  Future<void> limpiarSalasAntiguas() async {
    try {
      final haceDosHoras = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();

      // Buscamos las sesiones cuya fecha de creación sea anterior a hace 2 horas
      final snapshot = await _db
          .ref('sessions')
          .orderByChild('creadoEn')
          .endAt(haceDosHoras)
          .get();

      if (snapshot.exists) {
        final updates = <String, dynamic>{};
        for (var child in snapshot.children) {
          updates[child.key!] = null; // null elimina el nodo
        }

        if (updates.isNotEmpty) {
          // Eliminamos las sesiones de Realtime Database
          await _db.ref('sessions').update(updates);
          
          debugPrint('🗑️ Se limpiaron ${updates.length} salas antiguas de más de 2 horas.');
        }
      }
    } catch (e) {
      debugPrint('Error limpiando salas antiguas: $e');
    }
  }
}
