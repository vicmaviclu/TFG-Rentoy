import 'package:flutter/material.dart';
import '../../../core/constantes/cadenas.dart';
import '../../../core/constantes/textos.dart';
import '../../../core/constantes/colores.dart';

/// Selector simple de avatar: muestra círculo con número y botones para cambiar.
class AvatarSelector extends StatelessWidget {
  const AvatarSelector({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  final int valor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colores.primario,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$valor',
              style: EstilosTexto.tituloMedio.copyWith(color: Colores.blanco),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => onChanged((valor - 1).clamp(1, 9)),
              icon: const Icon(Icons.remove_circle_outline),
              color: Colores.textoPrimario,
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
              onPressed: () => onChanged((valor + 1).clamp(1, 9)),
              icon: const Icon(Icons.add_circle_outline),
              color: Colores.textoPrimario,
            ),
          ],
        ),
      ],
    );
  }
}
