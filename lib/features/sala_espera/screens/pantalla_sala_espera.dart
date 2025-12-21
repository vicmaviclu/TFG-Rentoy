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
  bool _pinCooldown = false;

  // Cached streams to prevent re-creation on setState
  late Stream<List<UsuarioModel>> _playersStream;
  late Stream<DatabaseEvent> _sessionStream;

  void _handleCopyPin(String pin) {
    if (_pinCooldown) return;

    setState(() {
      _pinCooldown = true;
    });

    Clipboard.setData(ClipboardData(text: pin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TextoPartida.pinCopiado),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _pinCooldown = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Instanciamos el controlador
    _controller = SalaEsperaController(servicio: ServicioRealtime());
    // Initializing streams once
    _playersStream = _controller.playersStream(
      widget.sessionId,
      widget.maxPlayers,
    );
    _sessionStream = _controller.sessionStream(widget.sessionId);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      showTitle: false,
      scrollable: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalH = constraints.maxHeight;
          final totalW = constraints.maxWidth;

          // Logo size
          double logoSize = (totalW * 0.45).clamp(100.0, 280.0);

          // Margins for the card
          final double cardTopMargin = logoSize * 0.5;

          return SizedBox(
            height: totalH,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // 1. Session Header (Back/Home button)
                // Moved down a bit to avoid feeling "too separated" or high up.
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(child: _buildSessionHeader()),
                ),

                // 2. Main Card Container (starts lower to allow logo overlap)
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        cardTopMargin +
                        4, // Reduced from + 20 to + 4 to move card up
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // User requested lighter green, similar to background.
                      // Background is Colores.fondo. Let's use Colores.fondo with high opacity or just Colores.primario.
                      // Actually, if we want it to look "like the background" but still distinct,
                      // maybe just slightly darker or lighter.
                      // Let's try Colores.primario (which is #2E8B57) vs #1B5E20 (previous).
                      // Colores.primario is lighter than #1B5E20.
                      color: const Color(0xFF2E8B57), // Colores.primario
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF1B5E20), // Darker green border
                        width: 4,
                      ),
                      boxShadow: [
                        // Depth effect
                        BoxShadow(
                          color: Colors.black26, // Softer shadow
                          offset: const Offset(0, 8),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height:
                              (logoSize * 0.5) +
                              0, // Reduced from + 10 to 0 for minimal space
                        ), // Space for the logo half
                        // Room Info (Host + PIN)
                        _buildRoomInfo(),

                        const Divider(
                          color: Colores.blanco12,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),

                        // Team Headers
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Equipo 1",
                                    style: EstilosTexto.subtitulo.copyWith(
                                      color: Colores.secundario,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Equipo 2",
                                    style: EstilosTexto.subtitulo.copyWith(
                                      color: Colores.secundario,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Players Grid
                        Expanded(
                          child: StreamBuilder<List<UsuarioModel>>(
                            stream: _playersStream,
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

                              // We use the same GridView, but visual columns "Team 1" / "Team 2"
                              // index 0 -> Left, index 1 -> Right, etc.
                              // Create rows for the grid
                              // 2 columns fixas implies we need (total / 2) rows.
                              final int rows = (widget.maxPlayers / 2).ceil();

                              return Column(
                                children: [
                                  // Use Expanded for the grid area so it fills available space
                                  Expanded(
                                    child: Column(
                                      children: List.generate(rows, (rowIndex) {
                                        // Calculates indexes for this row
                                        final index1 = rowIndex * 2;
                                        final index2 = index1 + 1;

                                        // Player data
                                        final info1 = index1 < players.length
                                            ? players[index1]
                                            : null;
                                        final info2 = index2 < players.length
                                            ? players[index2]
                                            : null;

                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                              left: 12,
                                              right: 12,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Column 1 (Team 1)
                                                Expanded(
                                                  child: JugadorTile(
                                                    nombre:
                                                        info1?.nombreUsuario,
                                                    uid: info1?.uid,
                                                    avatarIndex: info1?.avatar,
                                                    isHost: index1 == 0,
                                                    onTap: () => _handleSlotTap(
                                                      index1 + 1,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Column 2 (Team 2)
                                                Expanded(
                                                  child: JugadorTile(
                                                    nombre:
                                                        info2?.nombreUsuario,
                                                    uid: info2?.uid,
                                                    avatarIndex: info2?.avatar,
                                                    isHost:
                                                        index2 ==
                                                        0, // Should not happen for index 1+ usually
                                                    onTap: () => _handleSlotTap(
                                                      index2 + 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),

                                  // Action Buttons inside the card (at bottom)
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: _buildActionButtons(isFull),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Floating Logo (Top Center)
                Positioned(
                  top: 20, // Adjust based on SafeArea or desired top offset
                  child: Image.asset(
                    Recursos.logo,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionHeader() {
    return StreamBuilder<DatabaseEvent>(
      stream: _sessionStream,
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

        return IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 30),
          onPressed: () => _handleExit(amIHost),
        );
      },
    );
  }

  // Renamed and simplified to just content, not the container
  Widget _buildRoomInfo() {
    return StreamBuilder<DatabaseEvent>(
      stream: _sessionStream,
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

        return Column(
          children: [
            Text(
              TextoPartida.salaEspera, // "Sala de espera"
              style: EstilosTexto.tituloMedio.copyWith(
                color: Colores.blanco,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Partida de $anfitrionDb", // "Partida de ..."
              style: EstilosTexto.subtitulo.copyWith(
                color: Colores.blanco70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (pin.isNotEmpty)
              GestureDetector(
                onTap: () => _handleCopyPin(pin),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.secundario,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PIN: ",
                        style: EstilosTexto.cuerpoNegrita.copyWith(
                          color: Colores.textoPrimario,
                        ),
                      ),
                      SelectableText(
                        pin,
                        style: EstilosTexto.tituloMedio.copyWith(
                          fontFamily: 'monospace',
                          color: Colores.textoPrimario,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: () => _handleCopyPin(pin),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.copy, size: 18, color: Colores.textoPrimario),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
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
