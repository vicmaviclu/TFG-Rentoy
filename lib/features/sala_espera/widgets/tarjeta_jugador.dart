import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constantes/colores.dart';
import '../../../../core/constantes/textos.dart';

import '../../../../core/constantes/cadenas.dart';
import '../../../../core/constantes/recursos.dart';
import '../../../../models/usuario_model.dart';

/// Tarjeta individual de un jugador en la sala.
class TarjetaJugador extends StatefulWidget {
  final String? nombre;
  final String? uid;
  final int? indiceAvatar;
  final bool esAnfitrion;
  final VoidCallback? alPulsar;
  const TarjetaJugador({
    super.key,
    this.nombre,
    this.uid,
    this.indiceAvatar,
    this.esAnfitrion = false,
    this.alPulsar,
  });

  @override
  State<TarjetaJugador> createState() => _TarjetaJugadorState();
}

class _TarjetaJugadorState extends State<TarjetaJugador> {
  String? _nombreMostrar;
  int? _avatarResuelto;

  @override
  void initState() {
    super.initState();
    _nombreMostrar = widget.nombre;
    _intentarResolverNombre();
  }

  Future<void> _intentarResolverNombre() async {
    if (widget.uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .get();
        if (doc.exists) {
          final usuarioModelo = UsuarioModel.fromDocument(doc);
          if (mounted) {
            setState(() {
              _nombreMostrar = usuarioModelo.nombreUsuario;
              _avatarResuelto = usuarioModelo.avatar;
            });
          }
          return;
        }
      } catch (_) {}
    }

    // fallback: si parece email, quitamos dominio
    if ((_nombreMostrar ?? '').contains('@')) {
      if (mounted) {
        setState(() {
          _nombreMostrar = (_nombreMostrar ?? '').replaceAll(
            RegExp(r'@.*'),
            '',
          );
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant TarjetaJugador oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nombre != oldWidget.nombre || widget.uid != oldWidget.uid) {
      _nombreMostrar = widget.nombre;
      _intentarResolverNombre();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textoMostrar = (_nombreMostrar ?? '').isNotEmpty
        ? _nombreMostrar!
        : TextoPartida.esperando;

    final bool esHuecoVacio = widget.uid == null || (widget.uid!.isEmpty);

    if (esHuecoVacio) {
      // Estado: Hueco vacío (esperando jugador)
      return GestureDetector(
        onTap: widget.alPulsar,
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
            TextoPartida.esperando,
            style: EstilosTexto.cuerpo.copyWith(
              color: Colores.blanco70,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Estado: Hueco ocupado (muestra jugador)
    return GestureDetector(
      onTap: widget.alPulsar,
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
            if (_avatarResuelto != null || widget.indiceAvatar != null)
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
                        _avatarResuelto ?? widget.indiceAvatar ?? 1,
                      ),
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Center(
                        child: Text(
                          textoMostrar.isNotEmpty
                              ? textoMostrar[0].toUpperCase()
                              : '?',
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
                  textoMostrar.isNotEmpty ? textoMostrar[0].toUpperCase() : '?',
                  style: EstilosTexto.cuerpo.copyWith(color: Colores.blanco),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                textoMostrar,
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
