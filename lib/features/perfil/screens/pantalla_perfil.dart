import 'package:flutter/material.dart';

import '../controllers/controlador_perfil.dart';
import '../widgets/scaffold_perfil.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final ControladorPerfil controlador = ControladorPerfil();

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PerfilScaffold(controlador: controlador);
  }
}
