import 'package:flutter/material.dart';
import '../../../features/crear_partida/screens/pantalla_sala_espera.dart';

/// Archivo compatibilidad: reexpone la pantalla en español.
class WaitingRoomScreen extends StatelessWidget {
  final String sessionId;
  final String hostName;
  final int maxPlayers;

  const WaitingRoomScreen({super.key, required this.sessionId, required this.hostName, required this.maxPlayers});

  @override
  Widget build(BuildContext context) => PantallaSalaEspera(sessionId: sessionId, hostName: hostName, maxPlayers: maxPlayers);
}
