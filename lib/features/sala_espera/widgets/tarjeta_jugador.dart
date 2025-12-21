import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constantes/colores.dart';
import '../../../../core/constantes/textos.dart';

import '../../../../core/constantes/cadenas.dart';
import '../../../../core/constantes/recursos.dart';
import '../../../../models/usuario_model.dart';

class JugadorTile extends StatefulWidget {
  final String? nombre;
  final String? uid;
  final int? avatarIndex;
  final bool isHost;
  final VoidCallback? onTap;
  const JugadorTile({
    super.key,
    this.nombre,
    this.uid,
    this.avatarIndex,
    this.isHost = false,
    this.onTap,
  });

  @override
  State<JugadorTile> createState() => _JugadorTileState();
}

class _JugadorTileState extends State<JugadorTile> {
  String? _displayName;
  int? _resolvedAvatar;

  @override
  void initState() {
    super.initState();
    _displayName = widget.nombre;
    _tryResolveName();
  }

  Future<void> _tryResolveName() async {
    // if current name looks like an email and we have uid, try to fetch the proper username
    if (widget.uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .get();
        if (doc.exists) {
          final userModel = UsuarioModel.fromDocument(doc);
          if (mounted) {
            setState(() {
              _displayName = userModel.nombreUsuario;
              _resolvedAvatar = userModel.avatar;
            });
          }
          return;
        }
      } catch (_) {}
    }

    // fallback: if display looks like email, strip domain
    if ((_displayName ?? '').contains('@')) {
      if (mounted) {
        setState(() {
          _displayName = (_displayName ?? '').replaceAll(RegExp(r'@.*'), '');
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant JugadorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nombre != oldWidget.nombre || widget.uid != oldWidget.uid) {
      _displayName = widget.nombre;
      _tryResolveName();
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = (_displayName ?? '').isNotEmpty
        ? _displayName!
        : TextoPartida.esperando;

    // Check if slot is effectively empty (no name/uid)
    // In our logic, waiting slots usually have name="" or "Esperando..." depending on upstream
    // But usually waiting players in the stream have empty name if not joined.
    // Let's rely on whether we have a valid display name that is NOT the placeholder, OR a valid UID.

    final bool isEmptySlot = widget.uid == null || (widget.uid!.isEmpty);

    if (isEmptySlot) {
      // Diseño de "hueco vacío" (Empty Slot)
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(
              0xFF1B5E20,
            ).withOpacity(0.6), // Verde oscuro traslúcido
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(31, 15, 11, 11),
              width: 2,
            ), // Borde suave
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            TextoPartida.esperando, // "Esperando..."
            style: EstilosTexto.cuerpo.copyWith(
              color: Colores.blanco70,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Diseño de "Slot ocupado" (Filled Slot)
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colores.blanco12, // Fondo semi-claro para destacar jugador
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colores.blanco24), // Borde sutil
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // avatar
            if (_resolvedAvatar != null || widget.avatarIndex != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colores.blanco24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      Recursos.obtenerAvatar(
                        _resolvedAvatar ?? widget.avatarIndex ?? 1,
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Center(
                        child: Text(
                          display.isNotEmpty ? display[0].toUpperCase() : '?',
                          style: EstilosTexto.cuerpo.copyWith(
                            color: Colores.blanco,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: 22,
                backgroundColor: Colores.acento,
                child: Text(
                  display.isNotEmpty ? display[0].toUpperCase() : '?',
                  style: EstilosTexto.cuerpo.copyWith(color: Colores.blanco),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display,
                style: EstilosTexto.cuerpoNegrita.copyWith(
                  color: Colores.blanco,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
