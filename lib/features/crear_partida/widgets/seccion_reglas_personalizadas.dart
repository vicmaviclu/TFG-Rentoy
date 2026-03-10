import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/controlador_crear_partida.dart';
import '../../../core/constantes/colores.dart';
import '../../../core/constantes/textos.dart';

/// Widget que muestra la sección opcional de reglas personalizadas
/// en la pantalla de crear partida.
class SeccionReglasPersonalizadas extends StatelessWidget {
  final ControladorCrearPartida controlador;

  const SeccionReglasPersonalizadas({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: controlador.toggleMostrarReglas,
          child: Row(
            children: [
              Icon(
                controlador.mostrarReglas
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colores.blanco70,
              ),
              const SizedBox(width: 8),
              Text(
                'Jerarquía de cartas (Opcional)',
                style: EstilosTexto.subtitulo.copyWith(color: Colores.blanco70),
              ),
            ],
          ),
        ),
        if (controlador.mostrarReglas) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colores.blanco.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: controlador.cartasEspecialesDisponibles.map((
                cartaData,
              ) {
                final id = cartaData['id']!;
                final nombre = cartaData['nombre']!;
                final valor = controlador.configuracionCartas[id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: EstilosTexto.cuerpo.copyWith(
                            color: Colores.blanco,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        height: 36,
                        child: TextFormField(
                          key: ValueKey('${id}_${valor ?? ''}'),
                          initialValue: valor?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[1-5]')),
                            LengthLimitingTextInputFormatter(1),
                          ],
                          style: EstilosTexto.cuerpo.copyWith(
                            color: Colores.textoPrimario,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                            filled: true,
                            fillColor: Colores.blanco.withAlpha(200),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) =>
                              controlador.actualizarRegla(id, val),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
