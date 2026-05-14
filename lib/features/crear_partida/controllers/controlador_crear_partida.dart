import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/constantes/cadenas.dart';
import '../../perfil/controllers/controlador_perfil.dart';

/// Controlador para la creación de partidas.
class ControladorCrearPartida extends ChangeNotifier {
  final ServicioRealtime _servicio = ServicioRealtime();
  final ControladorPerfil _perfil = ControladorPerfil();

  int _maxJugadores = 2;
  int get maxJugadores => _maxJugadores;
  set maxJugadores(int value) {
    if (_maxJugadores != value) {
      _maxJugadores = value;
      _inicializarReglas();
      notifyListeners();
    }
  }

  bool cargando = false;
  bool mostrarReglas = false;

  // Mapa con las reglas personalizadas (ID Carta -> Posición/Fuerza 1,2,3...)
  final Map<String, int?> configuracionCartas = {};

  final List<Map<String, String>> cartasEspecialesDisponibles = [
    {'id': '11_oros', 'nombre': TextoCartas.onceOrosTuerto},
    {'id': '10_oros', 'nombre': TextoCartas.diezOrosPerica},
    {'id': '5_oros', 'nombre': TextoCartas.cincoOrosPablo},
    {'id': '3_muestra', 'nombre': TextoCartas.tresMuestra},
    {'id': '2_muestra', 'nombre': TextoCartas.dosMuestra},
  ];

  ControladorCrearPartida() {
    _inicializarReglas();
    _perfil.addListener(_onPerfilChanged);
  }

  void _onPerfilChanged() {
    notifyListeners();
  }

  void _inicializarReglas() {
    configuracionCartas.clear();
    for (var carta in cartasEspecialesDisponibles) {
      configuracionCartas[carta['id']!] = null;
    }

    // Valores por defecto según número de jugadores
    if (_maxJugadores == 4) {
      configuracionCartas['11_oros'] = 1;
      configuracionCartas['3_muestra'] = 2;
      configuracionCartas['2_muestra'] = 3;
    } else if (_maxJugadores == 6) {
      configuracionCartas['10_oros'] = 1;
      configuracionCartas['5_oros'] = 2;
      configuracionCartas['11_oros'] = 3;
      configuracionCartas['3_muestra'] = 4;
      configuracionCartas['2_muestra'] = 5;
    } else if (_maxJugadores == 2) {
      configuracionCartas['3_muestra'] = 1;
      configuracionCartas['2_muestra'] = 2;
    }
  }

  bool get reglasValidas {
    final values = _obtenerReglasValidas().values.toList();
    final uniqueValues = values.toSet();
    return values.length == uniqueValues.length;
  }

  void toggleMostrarReglas() {
    mostrarReglas = !mostrarReglas;
    notifyListeners();
  }

  void actualizarRegla(String idCarta, String valor) {
    if (valor.trim().isEmpty) {
      configuracionCartas[idCarta] = null;
    } else {
      int? rank = int.tryParse(valor);
      if (rank != null && rank > 0) {
        configuracionCartas[idCarta] = rank;
      }
    }
    notifyListeners();
  }

  // Filtrar nulos para guardar en DB
  Map<String, int> _obtenerReglasValidas() {
    final Map<String, int> validas = {};
    configuracionCartas.forEach((key, value) {
      if (value != null) {
        validas[key] = value;
      }
    });
    return validas;
  }

  // Obtiene el nombre del anfitrión desde el perfil o Auth
  String get nombreAnfitrion {
    final perfilName = _perfil.controladorNombreUsuario.text.trim();
    if (perfilName.isNotEmpty) return perfilName;
    final user = _perfil.usuario as User?;
    if (user == null) return TextoPerfil.jugadorDefecto;
    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : TextoPerfil.jugadorDefecto;
  }

  // Carga los datos del perfil de usuario
  Future<void> cargarPerfil() => _perfil.cargarPerfil();

  // Crea una nueva sesión de juego y retorna su ID
  Future<String> crearSesion() async {
    final nombre = nombreAnfitrion;
    cargando = true;
    notifyListeners();
    try {
      final id = await _servicio.crearSesion(
        hostName: nombre,
        maxPlayers: maxJugadores,
        avatar: _perfil.avatarSeleccionado,
        reglasPersonalizadas: _obtenerReglasValidas(),
      );
      return id;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _perfil.removeListener(_onPerfilChanged);
    _perfil.dispose();
    super.dispose();
  }
}
