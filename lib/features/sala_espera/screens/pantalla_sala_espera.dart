import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../core/widgets/pagina_fondo.dart';
import '../../../core/constantes/recursos.dart';

import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';
import '../controllers/controlador_sala_espera.dart';
import '../../../models/usuario_model.dart';
import '../widgets/tarjeta_jugador.dart';

class PantallaSalaEspera extends StatefulWidget {
  final String sessionId;
  final String hostName;
  final int maxPlayers;

  const PantallaSalaEspera({
    super.key,
    required this.sessionId,
    required this.hostName,
    required this.maxPlayers,
  });

  @override
  State<PantallaSalaEspera> createState() => _PantallaSalaEsperaState();
}

class _PantallaSalaEsperaState extends State<PantallaSalaEspera> {
  late SalaEsperaController _controller;

  @override
  void initState() {
    super.initState();
    // Instanciamos el controlador. Podríamos usar inyección de dependencias (GetIt/Provider)
    // pero por ahora lo creamos aquí asegurando un Singleton de servicio si fuese necesario.
    _controller = SalaEsperaController(servicio: ServicioRealtime());
  }

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      showTitle: false,
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // With scrollable: false, constraints should be finite/screen-bound.
            final totalH = constraints.maxHeight;
            // Adaptive logic for logo size
            double logoSize = (constraints.maxWidth * 0.32)
                .clamp(80.0, 260.0)
                .toDouble();
            final maxLogoByHeight = totalH * 0.16;
            if (logoSize > maxLogoByHeight) logoSize = maxLogoByHeight;

            return SizedBox(
              height: totalH, // Force full height to allow spacer/expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSessionHeader(),
                  // central rounded card
                  _buildInfoCard(logoSize),

                  // players grid + actions
                  Expanded(
                    child: StreamBuilder<List<UsuarioModel>>(
                      stream: _controller.playersStream(
                        widget.sessionId,
                        widget.maxPlayers,
                      ),
                      builder: (context, snapPlayers) {
                        if (snapPlayers.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final players =
                            snapPlayers.data ??
                            List<UsuarioModel>.filled(
                              widget.maxPlayers,
                              UsuarioModel(
                                uid: '',
                                email: '',
                                nombreUsuario: '',
                                avatar: 1,
                              ),
                            );
                        final isFull =
                            players
                                .where((p) => p.nombreUsuario.isNotEmpty)
                                .length >=
                            widget.maxPlayers;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(
                              child: GridView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 4.2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: widget.maxPlayers,
                                itemBuilder: (context, index) {
                                  final info = index < players.length
                                      ? players[index]
                                      : null;
                                  return JugadorTile(
                                    nombre: info?.nombreUsuario,
                                    uid: info?.uid,
                                    avatarIndex: info?.avatar,
                                    isHost: index == 0,
                                    onTap: () async {
                                      _handleSlotTap(index + 1);
                                    },
                                  );
                                },
                              ),
                            ),
                            const Spacer(), // Push buttons to bottom if space permits
                            _buildActionButtons(isFull),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionHeader() {
    return StreamBuilder<DatabaseEvent>(
      stream: _controller.sessionStream(widget.sessionId),
      builder: (context, sessionSnap) {
        final sVal = sessionSnap.hasData
            ? sessionSnap.data!.snapshot.value as dynamic
            : null;
        final anfitrionDb = sVal != null && sVal['anfitrion'] != null
            ? sVal['anfitrion'].toString()
            : widget.hostName;

        final currentDisplay =
            FirebaseAuth.instance.currentUser?.displayName ?? '';
        final amIHost =
            currentDisplay.isNotEmpty &&
            anfitrionDb.isNotEmpty &&
            currentDisplay == anfitrionDb;

        return Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => _handleExit(amIHost),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(double logoSize) {
    return StreamBuilder<DatabaseEvent>(
      stream: _controller.sessionStream(widget.sessionId),
      builder: (context, sessionSnap) {
        final sVal = sessionSnap.hasData
            ? sessionSnap.data!.snapshot.value as dynamic
            : null;
        final pin = sVal != null && sVal['pin'] != null
            ? sVal['pin'].toString()
            : '';
        final anfitrionDb = sVal != null && sVal['anfitrion'] != null
            ? sVal['anfitrion'].toString()
            : widget.hostName;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colores.blanco12,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Image.asset(
                Recursos.logo,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              Text(
                TextoPartida.salaEspera,
                style: EstilosTexto.tituloMedio.copyWith(color: Colores.blanco),
              ),
              const SizedBox(height: 6),
              Text(
                '${TextoPartida.anfitrion}: $anfitrionDb',
                style: EstilosTexto.subtitulo.copyWith(color: Colores.blanco70),
              ),
              const SizedBox(height: 8),
              if (pin.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.blanco24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PIN: ',
                        style: EstilosTexto.cuerpoNegrita.copyWith(
                          color: Colores.blanco,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SelectableText(
                        pin,
                        style: EstilosTexto.cuerpo.copyWith(
                          fontFamily: 'monospace',
                          color: Colores.blanco,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colores.blanco),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(TextoPartida.pinCopiado)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(bool isFull) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(
                TextoPartida.invitarJugadores,
                style: EstilosTexto.boton.copyWith(color: Colores.blanco),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.blanco24,
                foregroundColor: Colores.blanco,
              ),
              onPressed: () {
                // TODO: Implementar invitación
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull ? Colores.secundario : Colores.blanco12,
                foregroundColor: isFull
                    ? Colores.textoPrimario
                    : Colores.blanco70,
              ),
              onPressed: isFull ? () {} : null,
              child: Text(
                TextoPartida.empezarPartida,
                style: EstilosTexto.cuerpoNegrita.copyWith(
                  color: isFull ? Colores.textoPrimario : Colores.blanco70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSlotTap(int slot) async {
    try {
      await _controller.tomarHueco(widget.sessionId, slot);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleExit(bool amIHost) async {
    if (amIHost) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancelar partida'),
          content: const Text('Si sales, la partida se eliminará. ¿Continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );
      if (ok == true) {
        try {
          await _controller.cancelarSesion(widget.sessionId);
          if (!mounted) return;
          Navigator.of(context).pop();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } else {
      try {
        await _controller.salirDeSesion(widget.sessionId);
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}
