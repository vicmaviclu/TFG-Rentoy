import 'package:flutter/material.dart';
import '../../../../core/widgets/pagina_fondo.dart';
class PantallaPlantilla extends StatelessWidget {
  const PantallaPlantilla({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaFondo(
      showTitle: true,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Builder(builder: (context) {
            final size = MediaQuery.of(context).size;
            return SizedBox(
              height: size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pantalla Plantilla',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
