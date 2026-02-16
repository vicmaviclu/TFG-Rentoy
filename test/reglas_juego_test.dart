import 'package:flutter_test/flutter_test.dart';

import 'package:rentoy/models/carta_model.dart';
import 'package:rentoy/models/baraja_model.dart';

void main() {
  group('ReglasJuego con Baraja Eager Calculation', () {
    Carta crearCarta(int numero, String palo) {
      final prefijo = palo[0];
      final path =
          'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

      // Inicialmente valor 0
      return Carta(numero: numero, palo: palo, valor: 0, foto: path);
    }

    test('Jerarquía Triunfo: 2 debe ganar a 12', () {
      final dosTriunfo = crearCarta(2, 'Oros');
      final reyTriunfo = crearCarta(12, 'Oros');
      final paloMuestra = 'Oros';

      Baraja.calcularValores([dosTriunfo, reyTriunfo], paloMuestra, 'Oros', 4);

      expect(dosTriunfo.valor, greaterThan(reyTriunfo.valor));
    });

    test('Jerarquía Normal: 12 debe ganar a 2', () {
      final dosNormal = crearCarta(2, 'Copas');
      final reyNormal = crearCarta(12, 'Copas');
      final paloMuestra = 'Oros';

      Baraja.calcularValores([dosNormal, reyNormal], paloMuestra, 'Copas', 4);

      expect(reyNormal.valor, greaterThan(dosNormal.valor));
    });

    test('Triunfo gana a Palo Salida', () {
      final tresTriunfo = crearCarta(3, 'Oros');
      final reySalida = crearCarta(12, 'Copas');
      final paloMuestra = 'Oros';
      final paloSalida = 'Copas';

      Baraja.calcularValores(
        [tresTriunfo, reySalida],
        paloMuestra,
        paloSalida,
        4,
      );

      expect(tresTriunfo.valor, greaterThan(reySalida.valor));
    });

    test('Palo Salida gana a Otro Palo (no triunfo)', () {
      final dosSalida = crearCarta(2, 'Copas');
      final reyOtro = crearCarta(12, 'Espadas');
      final paloMuestra = 'Oros';
      final paloSalida = 'Copas';

      Baraja.calcularValores([dosSalida, reyOtro], paloMuestra, paloSalida, 4);

      expect(dosSalida.valor, greaterThan(reyOtro.valor));
    });

    test('Resetear valores pone puntos a 0', () {
      final carta = crearCarta(2, 'Oros');
      // Primero calculamos
      Baraja.calcularValores([carta], 'Oros', 'Oros', 4);
      expect(carta.valor, greaterThan(0));

      // Reseteamos
      Baraja.resetearValores([carta]);
      expect(carta.valor, equals(0));
    });
  });
}
