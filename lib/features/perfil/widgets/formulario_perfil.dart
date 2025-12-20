import 'package:flutter/material.dart';

import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';
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

    // Use a scroll view to avoid overflow on small devices and keep spacing consistent
    final fieldStyle = EstilosTexto.cuerpo.copyWith(
      color: Colores.textoPrimario,
    );
    // Simple filled decoration matching other forms in the app and using core label style
    InputDecoration simpleDecoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colores.superficie,
      labelStyle: EstilosTexto.caption.copyWith(color: Colores.textoSecundario),
    );

    // TarjetaAuth already provides a SingleChildScrollView, so we just return the content.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            // Let the parent TarjetaAuth provide the surface color. Use transparent here
            color: Colores.transparente,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Back Button + Title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colores.textoPrimario,
                    iconSize: 28,
                    tooltip: 'Volver',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      TextoComun.nombreApp,
                      style: EstilosTexto.titulo.copyWith(
                        color: Colores.textoPrimario,
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 28), // Balance for back button
                ],
              ),
              const SizedBox(height: 24),

              // Avatar box (rounded square with white border)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colores.primario,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colores.blanco12, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colores.negro12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/avatares/avatar ${c.avatarSeleccionado}.png',
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                '${c.avatarSeleccionado}',
                                style: EstilosTexto.titulo,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => c.avatarSeleccionado =
                        (c.avatarSeleccionado - 1).clamp(1, 9),
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Anterior avatar',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    TextoPerfil.avatar,
                    style: EstilosTexto.subtitulo.copyWith(
                      color: Colores.textoPrimario,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => c.avatarSeleccionado =
                        (c.avatarSeleccionado + 1).clamp(1, 9),
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Siguiente avatar',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Username
              TextFormField(
                controller: c.controladorNombreUsuario,
                style: fieldStyle,
                decoration: simpleDecoration(TextoPerfil.nombreUsuario),
              ),

              const SizedBox(height: 18),

              // Email (read-only display) — use same filled field style and mark disabled
              TextFormField(
                controller: c.controladorCorreo,
                readOnly: true,
                enabled: false,
                style: EstilosTexto.cuerpoNegrita.copyWith(
                  color: Colores.textoPrimario,
                ),
                decoration: simpleDecoration(
                  TextoAuth.correoHint,
                ).copyWith(suffixIcon: const Icon(Icons.lock_outline)),
              ),

              const SizedBox(height: 18),

              // Password
              TextFormField(
                controller: c.controladorContrasena,
                style: fieldStyle,
                decoration: simpleDecoration(TextoAuth.contrasenaHint),
                obscureText: true,
              ),

              const SizedBox(height: 22),

              // Actions
              if (c.cargando)
                const Center(child: CircularProgressIndicator())
              else ...[
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final msg = await c.guardarPerfil();
                      if (!mounted) return;
                      if (msg == null) {
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text(TextoComun.accionExitosa),
                          ),
                        );
                        navigator.pop();
                      } else {
                        scaffold.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.secundario,
                      foregroundColor: Colores.textoPrimario,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      TextoPerfil.guardarCambios,
                      style: EstilosTexto.cuerpoNegrita.copyWith(
                        color: Colores.textoPrimario,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: OutlinedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await widget.controlador.signOut();
                      if (!mounted) return;
                      navigator.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colores.negro12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    // Use the same bold body style as the primary button for consistency
                    child: Text(
                      TextoComun.cerrarSesion,
                      style: EstilosTexto.cuerpoNegrita.copyWith(
                        color: Colores.textoPrimario,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
