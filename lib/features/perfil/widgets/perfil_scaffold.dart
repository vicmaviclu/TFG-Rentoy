import 'package:flutter/material.dart';

import '../../auth/widgets/tarjeta_auth.dart';
import '../controllers/controlador_perfil.dart';
import 'perfil_form.dart';

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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
      body: Center(
        child: TarjetaAuth(
          size: size,
          child: PerfilForm(controlador: widget.controlador),
        ),
      ),
    );
  }
}
