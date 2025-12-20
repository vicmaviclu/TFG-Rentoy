class PartidaModel {
  final String id;
  final String pin;
  final String anfitrion;
  final int maxJugadores;
  final String estado;
  final List<String> jugadoresNombres; // Para Firestore
  final Map<String, dynamic>? jugadoresData; // Para Realtime
  final DateTime? creadoEn;

  PartidaModel({
    required this.id,
    required this.pin,
    required this.anfitrion,
    required this.maxJugadores,
    this.estado = 'esperando',
    this.jugadoresNombres = const [],
    this.jugadoresData,
    this.creadoEn,
  });

  /// Factory desde Realtime Database
  factory PartidaModel.fromRealtime(Map<String, dynamic> map, String id) {
    return PartidaModel(
      id: id,
      pin: map['pin']?.toString() ?? '',
      anfitrion: map['anfitrion']?.toString() ?? '',
      maxJugadores: (map['maxJugadores'] as int?) ?? 2,
      estado: map['estado']?.toString() ?? 'esperando',
      jugadoresData: map['jugadores'] is Map
          ? Map<String, dynamic>.from(map['jugadores'])
          : null,
      creadoEn: map['creadoEn'] != null
          ? DateTime.tryParse(map['creadoEn'].toString())
          : null,
    );
  }

  /// Factory desde Firestore
  factory PartidaModel.fromFirestore(Map<String, dynamic> map, String id) {
    List<String> jugadores = [];
    if (map['jugadores'] is List) {
      jugadores = List<String>.from(map['jugadores'].map((x) => x.toString()));
    }

    // DateTime? fecha; // Unused for now as we don't fully implement reading timestamp from firestore here without library import or dynamic check.
    // Firestore timestamp handling needs import or dynamic check if library not imported here.
    // Assuming Timestamp object usually comes from library. Since we don't import cloud_firestore here to keep it pure if possible,
    // we can treat as dynamic or just rely on standard types.
    // For simplicity, we'll keep it simple or import if needed.
    // Let's rely on standard logic used in app.

    return PartidaModel(
      id: id,
      pin: map['pin']?.toString() ?? '',
      anfitrion:
          map['anfitrion']?.toString() ??
          '', // A veces no está en firestore doc principal, depende esquema
      maxJugadores: (map['maxJugadores'] as int?) ?? 2,
      estado: map['estado']?.toString() ?? 'esperando',
      jugadoresNombres: jugadores,
    );
  }
}
