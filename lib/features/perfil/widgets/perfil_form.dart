import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../controllers/controlador_perfil.dart';

class PerfilForm extends StatefulWidget {
  final ControladorPerfil controlador;
  const PerfilForm({required this.controlador, super.key});

  @override
  State<PerfilForm> createState() => _PerfilFormState();
}

class _PerfilFormState extends State<PerfilForm> {
  @override
  void initState() {
    super.initState();
    widget.controlador.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    widget.controlador.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controlador;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 36,
          backgroundColor: Colores.primario,
          child: Text('${c.avatarSeleccionado}', style: const TextStyle(fontSize: 24, color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => c.avatarSeleccionado = (c.avatarSeleccionado - 1).clamp(1, 9),
                icon: const Icon(Icons.remove_circle_outline)),
            const SizedBox(width: 8),
            const Text(Cadenas.avatar),
            const SizedBox(width: 8),
            IconButton(
                onPressed: () => c.avatarSeleccionado = (c.avatarSeleccionado + 1).clamp(1, 9),
                icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(controller: c.controladorNombreUsuario, decoration: const InputDecoration(labelText: Cadenas.nombreUsuario)),
        const SizedBox(height: 8),
        // Mostramos el correo como texto no editable, para dejar claro que
        // no puede modificarse desde esta pantalla.
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(Cadenas.correoHint, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(c.controladorCorreo.text.isNotEmpty ? c.controladorCorreo.text : '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(controller: c.controladorContrasena, decoration: const InputDecoration(labelText: Cadenas.contrasenaHint), obscureText: true),
        const SizedBox(height: 16),
        c.cargando
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  final scaffold = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final msg = await c.guardarPerfil();
                  if (!mounted) return;
                  if (msg == null) {
                    scaffold.showSnackBar(const SnackBar(content: Text(Cadenas.accionExitosa)));
                    navigator.pop();
                  } else {
                    scaffold.showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                child: const Text(Cadenas.guardarCambios),
              ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            navigator.pop();
          },
          child: Text(Cadenas.cerrarSesion),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

