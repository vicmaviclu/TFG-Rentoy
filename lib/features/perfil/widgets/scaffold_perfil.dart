import 'package:flutter/material.dart';

// Clean imports — only used symbols are imported
import '../../../core/widgets/plantilla_pantalla_principal.dart';
import '../controllers/controlador_perfil.dart';
import 'formulario_perfil.dart';

class PerfilScaffold extends StatefulWidget {
  final ControladorPerfil controlador;
  const PerfilScaffold({required this.controlador, super.key});

  @override
  State<PerfilScaffold> createState() => _PerfilScaffoldState();
}

class _PerfilScaffoldState extends State<PerfilScaffold> {
  @override
  void initState() {
    super.initState();
    widget.controlador.cargarPerfil();
  }

  @override
  void dispose() {
    widget.controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaPantallaPrincipal(
      mostrarVolver: true,
      child: PerfilForm(controlador: widget.controlador),
    );
  }
}
