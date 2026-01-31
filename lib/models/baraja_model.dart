import 'dart:math';
import 'carta_model.dart';

class Baraja {
  List<Carta> cartas = [];

  Baraja() {
    _generarCartas();
  }

  void _generarCartas() {
    cartas = [];
    final palos = ['Oros', 'Copas', 'Espadas', 'Bastos'];

    for (var palo in palos) {
      // El prefijo es la primera letra del palo (O, C, E, B)
      final prefijo = palo[0];

      for (var i = 1; i <= 12; i++) {
        if (i == 8 || i == 9) continue; // No hay 8 ni 9 en la baraja

        final valor = _obtenerValor(i);
        final path = _obtenerRutaImagen(palo, prefijo, i);

        cartas.add(Carta(numero: i, palo: palo, valor: valor, foto: path));
      }
    }
  }

  /// Devuelve el valor de la carta (As=11, 3=10, etc.)
  int _obtenerValor(int numero) {
    switch (numero) {
      case 1:
        return 11;
      case 3:
        return 10;
      case 12: // Rey
        return 4;
      case 11: // Caballo
        return 3;
      case 10: // Sota
        return 2;
      default:
        return 0;
    }
  }

  /// Genera la ruta al asset
  String _obtenerRutaImagen(String palo, String prefijo, int numero) {
    return 'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';
  }

  void barajar() {
    cartas.shuffle(Random());
  }
}
