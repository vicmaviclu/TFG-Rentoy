import 'package:flutter/material.dart';
import '../../../features/crear_partida/screens/pantalla_crear_partida.dart';

/// Archivo compatibilidad: reexpone la pantalla en español.
class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context) => const PantallaCrearPartida();
}
