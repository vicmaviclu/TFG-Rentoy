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
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colores.blanco08,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colores.negro12, blurRadius: 6)],
          border: Border.all(color: Colores.blanco12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // avatar image if provided
            // prefer resolved avatar -> widget.avatarIndex -> fallback initial
            if (_resolvedAvatar != null || widget.avatarIndex != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colores.blanco24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
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
                radius: 20,
                backgroundColor: Colores.acento,
                child: Text(
                  display.isNotEmpty ? display[0].toUpperCase() : '?',
                  style: EstilosTexto.cuerpo.copyWith(color: Colores.blanco),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display,
                    style: EstilosTexto.cuerpo.copyWith(color: Colores.blanco),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
