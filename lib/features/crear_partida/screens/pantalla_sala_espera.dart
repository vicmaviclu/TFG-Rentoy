import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../servicios/servicio_realtime.dart';

class PantallaSalaEspera extends StatelessWidget {
  final String sessionId;
  final String hostName;
  final int maxPlayers;

  const PantallaSalaEspera({super.key, required this.sessionId, required this.hostName, required this.maxPlayers});

  @override
  Widget build(BuildContext context) {
    final servicio = ServicioRealtime();

    return Scaffold(
      appBar: AppBar(title: const Text('Sala de espera')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('ID de la partida: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(sessionId, style: const TextStyle(fontFamily: 'monospace'))),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sessionId));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado al portapapeles')));
                  },
                )
              ],
            ),
            const SizedBox(height: 12),
            const Text('Jugadores', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: servicio.streamSesion(sessionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data == null) return const Center(child: Text('Esperando datos...'));

                  final event = snapshot.data!;
                  final val = event.snapshot.value as dynamic;
                  final players = <String>[];

                  if (val != null && val['players'] != null) {
                    try {
                      final playersMap = Map<String, dynamic>.from(val['players']);
                      final keys = playersMap.keys.where((k) => k.toString().startsWith('jugador')).toList()
                        ..sort((a, b) {
                          final ai = int.tryParse(a.replaceAll('jugador', '')) ?? 0;
                          final bi = int.tryParse(b.replaceAll('jugador', '')) ?? 0;
                          return ai.compareTo(bi);
                        });

                      for (final k in keys) {
                        final v = playersMap[k];
                        if (v == null) {
                          continue;
                        }
                        if (v is String) {
                          players.add(v);
                        } else if (v is Map && v['name'] != null) {
                          players.add(v['name']);
                        }
                      }
                    } catch (_) {
                      // ignore parse errors
                    }
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: maxPlayers,
                    itemBuilder: (context, index) {
                      final name = index < players.length ? players[index] : '';
                      final isHost = index == 0;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 6)],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent,
                              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name.isNotEmpty ? name : 'Esperando...', style: const TextStyle(fontSize: 14)),
                                  if (isHost) const Text('Anfitrión', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Invitar jugadores'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
