import 'package:flutter/material.dart';

// Clean imports — only used symbols are imported
import '../../../core/widgets/pagina_fondo.dart';
import '../../auth/widgets/tarjeta_auth.dart';
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
    final size = MediaQuery.of(context).size;

    return PaginaFondo(
      showTitle: false,
      scrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Removed inline logo to avoid extra scrolling; keep compact layout
          const SizedBox(height: 6),
          TarjetaAuth(
            size: size,
            child: PerfilForm(controlador: widget.controlador),
          ),
        ],
      ),
    );
  }
}
