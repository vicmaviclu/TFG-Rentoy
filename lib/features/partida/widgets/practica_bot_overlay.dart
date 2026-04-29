import 'package:flutter/material.dart';
import '../../crear_partida/controllers/controlador_crear_partida.dart';
import '../../sala_espera/controllers/controlador_sala_espera.dart';
import '../../../core/servicios/servicio_realtime.dart';
import '../../../app/rutas.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/errores.dart';

/// Overlay de carga que inicializa la partida de práctica y salta la sala de espera.
class PracticaBotOverlay extends StatefulWidget {
  const PracticaBotOverlay({super.key});

  @override
  State<PracticaBotOverlay> createState() => _PracticaBotOverlayState();
}

class _PracticaBotOverlayState extends State<PracticaBotOverlay> {
  @override
  void initState() {
    super.initState();
    _iniciarPractica();
  }

  Future<void> _iniciarPractica() async {
    try {
      final ctrlCrear = ControladorCrearPartida();
      await ctrlCrear.cargarPerfil();
      ctrlCrear.maxJugadores = 2; // Forzamos 2 jugadores
      final idSesion = await ctrlCrear.crearSesion();

      // Inyectar el bot en el jugador 2
      final servicio = ServicioRealtime();
      await servicio
          .referenciaSesion(idSesion)
          .child('jugadores/jugador 2')
          .set({
            'name': 'Bot',
            'avatar': 2,
            'uid': 'bot_12345',
            'es_bot': true,
          });

      // Empezar la partida directamente
      final ctrlSala = ControladorSalaEspera(servicio: servicio);
      await ctrlSala.empezarPartida(idSesion);

      if (!mounted) return;

      // Cerrar el diálogo de carga y navegar a la partida
      final nav = Navigator.of(context, rootNavigator: true);
      nav.pop();
      nav.pushNamed(
        RutasApp.partida,
        arguments: {
          'idSesion': idSesion,
          'maxJugadores': 2,
          'conBot': true,
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ErroresPartida.errorCrear}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colores.transparente,
      elevation: 0,
      child: Center(
        child: CircularProgressIndicator(
          color: Colores.blanco,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
