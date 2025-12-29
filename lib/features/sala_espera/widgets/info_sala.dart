import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

/// Panel de información de la sala (PIN, Anfitrión).
class InfoSala extends StatefulWidget {
  final Stream<DatabaseEvent> streamSesion;
  final String nombreAnfitrion;

  const InfoSala({
    super.key,
    required this.streamSesion,
    required this.nombreAnfitrion,
  });

  @override
  State<InfoSala> createState() => _InfoSalaState();
}

class _InfoSalaState extends State<InfoSala> {
  bool _pinCooldown = false;

  void _copiarPin(BuildContext context, String pin) {
    if (_pinCooldown) return;

    setState(() => _pinCooldown = true);

    Clipboard.setData(ClipboardData(text: pin));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(TextoPartida.pinCopiado),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _pinCooldown = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.streamSesion,
      builder: (context, instantanea) {
        final valorSesion = instantanea.hasData
            ? instantanea.data!.snapshot.value as dynamic
            : null;
        final pin = valorSesion != null && valorSesion['pin'] != null
            ? valorSesion['pin'].toString()
            : '';
        final anfitrionDb =
            valorSesion != null && valorSesion['anfitrion'] != null
            ? valorSesion['anfitrion'].toString()
            : widget.nombreAnfitrion;

        return Column(
          children: [
            // Título de la sala
            Text(
              TextoPartida.salaEspera,
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
            // Nombre del anfitrión
            Text(
              "Partida de $anfitrionDb",
              style: EstilosTexto.subtitulo.copyWith(
                color: Colores.blanco70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (pin.isNotEmpty)
              // Muestra el PIN copiable
              GestureDetector(
                onTap: () => _copiarPin(context, pin),
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
                        onTap: () => _copiarPin(context, pin),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.copy,
                        size: 18,
                        color: Colores.textoPrimario,
                      ),
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
}
