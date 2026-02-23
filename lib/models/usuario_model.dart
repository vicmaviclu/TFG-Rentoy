import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String email;
  final String nombreUsuario;
  final int avatar;
  final DateTime? fechaCreacion;
  final List<dynamic>? mano;
  final String? keyJugador;

  UsuarioModel({
    required this.uid,
    this.email = '',
    required this.nombreUsuario,
    required this.avatar,
    this.fechaCreacion,
    this.mano,
    this.keyJugador,
  });

  /// Crea una copia del modelo con campos modificados
  UsuarioModel copyWith({
    String? uid,
    String? email,
    String? nombreUsuario,
    int? avatar,
    DateTime? fechaCreacion,
    String? keyJugador,
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      avatar: avatar ?? this.avatar,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      mano: mano ?? mano,
      keyJugador: keyJugador ?? this.keyJugador,
    );
  }

  /// Método para saber si es el turno de un jugador usando su keyJugador (ej: 'jugador 1')
  bool esSuTurno(int turnoActual) {
    if (keyJugador == null) return false;
    int? numeroJugador = int.tryParse(
      keyJugador!.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (numeroJugador != null) {
      return numeroJugador == turnoActual;
    }
    return false;
  }

  /// Convierte un Map de Firestore a UsuarioModel.
  /// Maneja variaciones en nombres de campo por compatibilidad.
  factory UsuarioModel.fromMap(Map<String, dynamic> map, String uid) {
    // Resolver nombre de usuario (preferencia: nombre_usuario -> nombreUsuario -> username -> name)
    String nombre = '';
    if (map['nombre_usuario'] != null) {
      nombre = map['nombre_usuario'].toString();
    } else if (map['nombreUsuario'] != null) {
      nombre = map['nombreUsuario'].toString();
    } else if (map['username'] != null) {
      nombre = map['username'].toString();
    } else if (map['name'] != null) {
      nombre = map['name'].toString();
    }

    // Resolver avatar
    int av = 1;
    if (map['avatar'] is int) {
      av = map['avatar'] as int;
    } else if (map['avatar'] != null) {
      av = int.tryParse(map['avatar'].toString()) ?? 1;
    }

    // Resolver fecha
    DateTime? fecha;
    if (map['fecha_creacion'] is Timestamp) {
      fecha = (map['fecha_creacion'] as Timestamp).toDate();
    } else if (map['fechaCreacion'] is Timestamp) {
      fecha = (map['fechaCreacion'] as Timestamp).toDate();
    } else if (map['fecha_creacion'] is String) {
      fecha = DateTime.tryParse(map['fecha_creacion']);
    }

    return UsuarioModel(
      uid: uid,
      email: map['email']?.toString() ?? '',
      nombreUsuario: nombre,
      avatar: av,
      fechaCreacion: fecha,
    );
  }

  factory UsuarioModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UsuarioModel.fromMap(data, doc.id);
  }

  /// Convierte el modelo a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre_usuario': nombreUsuario,
      'avatar': avatar,
      // Usamos el nombre estandarizado 'fecha_creacion'
      if (fechaCreacion != null)
        'fecha_creacion': Timestamp.fromDate(fechaCreacion!),
    };
  }
}
