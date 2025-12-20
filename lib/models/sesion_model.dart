class SesionModel {
  final String id;
  final String? anfitrion;
  final String? creadoEn; // ISO8601 string in realtime
  final String? estado;
  final int maxJugadores;
  final String? pin;
  final Map<String, dynamic> jugadores;

  SesionModel({
    required this.id,
    this.anfitrion,
    this.creadoEn,
    this.estado = 'esperando',
    this.maxJugadores = 2,
    this.pin,
    this.jugadores = const {},
  });

  factory SesionModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return SesionModel(
      id: id,
      anfitrion: map['anfitrion']?.toString(),
      creadoEn: map['creadoEn']?.toString(),
      estado: map['estado']?.toString(),
      maxJugadores: (map['maxJugadores'] is int)
          ? map['maxJugadores'] as int
          : int.tryParse(map['maxJugadores']?.toString() ?? '') ?? 2,
      pin: map['pin']?.toString(),
      jugadores: (map['jugadores'] is Map)
          ? Map<String, dynamic>.from(map['jugadores'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'anfitrion': anfitrion,
      'creadoEn': creadoEn,
      'estado': estado,
      'maxJugadores': maxJugadores,
      'pin': pin,
      'jugadores': jugadores,
    };
  }
}
