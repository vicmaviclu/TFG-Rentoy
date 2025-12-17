import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ServicioRealtime {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Crea una nueva sesión con código numérico de 6 dígitos y la guarda
  /// en Realtime Database y en Firestore (colección `partidas`).
  Future<String> crearSesion({
    required String hostName,
    required int maxPlayers,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Autenticación requerida. Inicia sesión para crear una partida.');
    final rnd = Random.secure();
    String codigo = '';
    const maxAttempts = 50;

    for (var i = 0; i < maxAttempts; i++) {
      codigo = (rnd.nextInt(900000) + 100000).toString();
      final q = await firestore.collection('partidas').where('codigo', isEqualTo: codigo).where('status', isEqualTo: 'esperando').limit(1).get();
      if (q.docs.isEmpty) break;
      if (i == maxAttempts - 1) throw Exception('No se pudo generar un código único');
    }

    final ref = _db.ref('sessions/$codigo');
    final now = DateTime.now().toIso8601String();

    final sessionData = {
      'id': codigo,
      'hostName': hostName,
      'maxPlayers': maxPlayers,
      'status': 'esperando',
      'createdAt': now,
      'players': {
        'jugador ': hostName,
      }
    };

    await ref.set(sessionData);

    final partidaDoc = firestore.collection('partidas').doc(codigo);
    await partidaDoc.set({
      'codigo': codigo,
      'players': [hostName],
      'status': 'esperando',
      'maxPlayers': maxPlayers,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
    });

    return codigo;
  }

  DatabaseReference referenciaSesion(String sessionId) => _db.ref('sessions/$sessionId');

  Stream<DatabaseEvent> streamSesion(String sessionId) => referenciaSesion(sessionId).onValue;

  /// Une a la sesión buscando el siguiente slot libre (jugador2..jugadorN)
  Future<void> unirASesion(String sessionId, String playerName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Autenticación requerida. Inicia sesión para unirte a una partida.');
    final ref = referenciaSesion(sessionId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Sesión no encontrada');

    final data = snap.value as dynamic;
    final maxPlayers = data['maxPlayers'] as int? ?? 2;

    Map players = {};
    try {
      if (data['players'] != null) players = Map.from(data['players']);
    } catch (_) {
      players = {};
    }

    int slot = 0;
    for (var i = 1; i <= maxPlayers; i++) {
      final key = 'jugador $i';
      final val = players.containsKey(key) ? players[key] : null;
      if (val == null || (val is String && val.isEmpty)) {
        slot = i;
        break;
      }
    }

    if (slot == 0) throw Exception('La sala está llena');

    final playerKey = 'jugador$slot';
    await ref.child('players/$playerKey').set(playerName);

    // Actualizar Firestore
    final firestore = FirebaseFirestore.instance;
    final partidaDoc = firestore.collection('partidas').doc(sessionId);
    final partidaSnap = await partidaDoc.get();
    if (partidaSnap.exists) {
      await partidaDoc.update({
        'players': FieldValue.arrayUnion([playerName])
      });
    }
  }
}
