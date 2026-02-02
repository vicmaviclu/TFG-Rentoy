import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/usuario_model.dart';

class ServicioRealtime {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Devuelve el nombre de usuario a usar (preferente: campo `name` o `username` en Firestore,
  /// luego displayName; nunca usar el email si es posible). Si no encuentra nada, usa `fallback` o 'Jugador'.
  Future<String> _resolvedUsernameForUser(
    String? providedName,
    String uid,
  ) async {
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
  /// Genera la escritura de forma optimista (sin esperar confirmación de red)
  /// para evitar bloqueos y timeouts en conexiones lentas.
  Future<String> crearSesion({
    required String hostName,
    required int maxPlayers,
    required int avatar,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(
        'Autenticación requerida. Inicia sesión para crear una partida.',
      );
    }
    final rnd = Random.secure();
    final pin = (rnd.nextInt(900000) + 100000).toString();

    final ref = _db.ref().child('sessions').push();
    final sessionId = ref.key ?? '';
    final now = DateTime.now().toIso8601String();

    // Host Display comes directly from arguments
    final hostDisplay = hostName.isEmpty ? 'Jugador' : hostName;

    final sessionData = {
      'pin': pin,
      'anfitrion': hostDisplay,
      'maxJugadores': maxPlayers,
      'estado': 'esperando',
      'creadoEn': now,
      'jugadores': {
        'jugador 1': {'name': hostDisplay, 'avatar': avatar, 'uid': user.uid},
      },
    };

    // Fire and forget - Do not await DB writes
    ref.set(sessionData).catchError((e) {
      print("Error writing session Rtdb: $e");
    });

    // Also fire-and-forget Firestore write
    final firestore = FirebaseFirestore.instance;
    firestore
        .collection('partidas')
        .doc(sessionId)
        .set({
          'pin': pin,
          'jugadores': [hostDisplay],
          'estado': 'esperando',
          'maxJugadores': maxPlayers,
          'creadoEn': FieldValue.serverTimestamp(),
        })
        .catchError((e) {
          print("Error writing session Firestore: $e");
        });

    return sessionId;
  }

  /// Sale de la sesión: elimina la entrada del jugador que coincide con el uid actual
  /// y actualiza el documento de Firestore eliminando el nombre del array `jugadores`.
  Future<void> salirDeSesion(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Autenticación requerida.');
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
        // if the slot stores a plain name, try to match by resolving current user's name
        final resolved = await _resolvedUsernameForUser(null, user.uid);
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
      throw Exception(
        'Autenticación requerida. Inicia sesión para unirte a una partida.',
      );
    }
    final ref = referenciaSesion(sessionId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw Exception('Sesión no encontrada');
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

    int slot = 0;
    bool alreadyIn = false;

    for (var i = 1; i <= maxPlayers; i++) {
      final key = 'jugador $i';
      final val = players.containsKey(key) ? players[key] : null;

      // Check if this slot belongs to current user
      if (val is Map && val['uid'] == user.uid) {
        alreadyIn = true;
        break; // Already joined, no need to add again
      }

      // Find first empty slot
      if (slot == 0 && (val == null || (val is String && val.isEmpty))) {
        slot = i;
      }
    }

    if (alreadyIn) {
      // If already in, just return success (idempotent)
      return;
    }

    if (slot == 0) {
      throw Exception('La sala está llena');
    }

    // fetch avatar for current user
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

    final resolvedName = await _resolvedUsernameForUser(playerName, user.uid);
    final playerKey = 'jugador $slot';
    // write as map with name, avatar and uid to allow avatars in UI
    await ref.child('jugadores/$playerKey').set({
      'name': resolvedName,
      'avatar': avatarIndex,
      'uid': user.uid,
    });

    // Actualizar Firestore (solo nombre)
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();
    if (partidaSnap.exists) {
      await partidaDoc.update({
        'jugadores': FieldValue.arrayUnion([resolvedName]),
      });
    }
  }

  /// Toma un hueco específico en la sesión (cambia de slot si ya estabas en otro).
  Future<void> tomarHueco(String sessionId, int slot) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Autenticación requerida.');
    }
    final ref = referenciaSesion(sessionId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw Exception('Sesión no encontrada');
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

    // resolve display name for current user (prefer usuarios doc, then displayName)
    final resolvedName = await _resolvedUsernameForUser(null, user.uid);

    // try to fetch avatar index for current user
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

    // 1. Check if target slot is occupied (BEFORE removing current slot)
    final targetKey = 'jugador $slot';
    final targetVal = players.containsKey(targetKey)
        ? players[targetKey]
        : null;

    if (targetVal != null) {
      if (targetVal is Map && targetVal['uid'] != null) {
        throw Exception('El hueco ya está ocupado');
      } else if (targetVal is String && targetVal.isNotEmpty) {
        throw Exception('El hueco ya está ocupado');
      }
    }

    // 2. Remove any existing slot for this uid (now safe to do)
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
      throw Exception('No se encontró ninguna partida con ese PIN.');
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
    // Extraemos info relevante para Firestore si existe en updates
    final nuevoEstado = updates['estado'];
    final puntos = updates['puntos'];
    final ronda = updates['rondas/actual']; // Cuidado con la clave anidada

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

  /// Juega una carta: marca usada, actualiza carta ganadora, pasa turno.
  Future<void> jugarCarta({
    required String sessionId,
    required String rondaId,
    required String jugadorKey,
    required int cartaIndex,
    required Map<String, dynamic> cartaData,
    required int nuevoTurno,
  }) async {
    final ref = referenciaSesion(sessionId);

    // Estructura de actualización
    final cardPath = 'rondas/$rondaId/$jugadorKey/$cartaIndex/usada';

    // Almacenamos quién ganó (por ahora, el que tiró último, simplificado)
    // TODO: Lógica real de quién gana la baza
    final winningPath = 'rondas/$rondaId/carta_ganadora';

    final turnoPath = 'rondas/$rondaId/turno';

    // Guardar info completa de la carta ganadora
    final dataGanadora = {
      'carta': cartaData,
      'jugador': jugadorKey,
      'equipo': (jugadorKey == 'jugador 1' || jugadorKey == 'jugador 3')
          ? 1
          : 2, // Simplificado, asumir orden estándar
    };

    await ref.update({
      cardPath: true,
      winningPath: dataGanadora,
      turnoPath: nuevoTurno,
    });
  }

  /// Limpia la mesa (no se usa si no hay mesa global, pero útil para resetear carta ganadora)
  Future<void> limpiarCartaGanadora(String sessionId, String rondaId) async {
    await referenciaSesion(
      sessionId,
    ).child('rondas/$rondaId/carta_ganadora').remove();
  }

  /// Escucha la carta ganadora de la ronda actual
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
}
