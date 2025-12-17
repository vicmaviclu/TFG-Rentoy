import 'package:flutter/material.dart';
import '../../../../core/widgets/pagina_fondo.dart';
import '../../../../core/constantes/cadenas.dart';

class PantallaUnirsePartida extends StatelessWidget {
  const PantallaUnirsePartida({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PaginaFondo(
      showTitle: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(
            height: size.height * 0.6,
            child: Center(
              child: Text(
                Cadenas.tituloUnirsePartida,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
