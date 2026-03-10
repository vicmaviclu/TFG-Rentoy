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

    group('Reglas Específicas 2 Jugadores', () {
      test('Tuerto (11 Oros) no es buena con en 2 jugadores', () {
        final tuerto = crearCarta(11, 'Oros');
        final reyOros = crearCarta(12, 'Oros'); // Rey de muestra
        final paloMuestra = 'Oros';

        Baraja.calcularValores([tuerto, reyOros], paloMuestra, 'Oros', 2);

        // En 2 jugadores, el 11 de muestra vale menos que el 12 de muestra
        expect(reyOros.valor, greaterThan(tuerto.valor));
      });
    });

    group('Reglas Específicas 4 Jugadores', () {
      test('Tuerto (11 Oros) es la mejor carta', () {
        final tuerto = crearCarta(11, 'Oros');
        final andorra = crearCarta(
          3,
          'Copas',
        ); // Supongamos que Copas es muestra
        final paloMuestra = 'Copas';

        Baraja.calcularValores([tuerto, andorra], paloMuestra, 'Copas', 4);

        expect(tuerto.valor, greaterThan(andorra.valor));
      });

      test('Falso Tuerto (11 de otro palo) no es buena carta', () {
        final falsoTuerto = crearCarta(
          11,
          'Copas',
        ); // Caballo de copas, no oros
        final dosMuestra = crearCarta(2, 'Espadas'); // 2 de muestra
        final paloMuestra = 'Espadas';

        Baraja.calcularValores(
          [falsoTuerto, dosMuestra],
          paloMuestra,
          'Espadas',
          4,
        );

        // El 2 de muestra debe ganar al 11 de un palo normal
        expect(dosMuestra.valor, greaterThan(falsoTuerto.valor));
      });

      test('Andorra (3 Muestra) gana a 2 y 12 Muestra', () {
        final andorra = crearCarta(3, 'Espadas'); // Muestra
        final dosMuestra = crearCarta(2, 'Espadas');
        final reyMuestra = crearCarta(12, 'Espadas');
        final paloMuestra = 'Espadas';

        Baraja.calcularValores(
          [andorra, dosMuestra, reyMuestra],
          paloMuestra,
          'Espadas',
          4,
        );

        expect(andorra.valor, greaterThan(dosMuestra.valor));
        expect(dosMuestra.valor, greaterThan(reyMuestra.valor));
      });
    });

    group('Reglas Específicas 6 Jugadores', () {
      test('Jerarquía de invencibles: Perica > Pablo > Tuerto > Andorra', () {
        final perica = crearCarta(10, 'Oros');
        final pablo = crearCarta(5, 'Oros');
        final tuerto = crearCarta(11, 'Oros');
        final andorra = crearCarta(3, 'Copas'); // Muestra
        final paloMuestra = 'Copas';

        Baraja.calcularValores(
          [perica, pablo, tuerto, andorra],
          paloMuestra,
          'Copas',
          6,
        );

        expect(perica.valor, greaterThan(pablo.valor));
        expect(pablo.valor, greaterThan(tuerto.valor));
        expect(tuerto.valor, greaterThan(andorra.valor));
      });

      test('Falsas cartas especiales de otros palos no son buenas cartas', () {
        final falsaPerica = crearCarta(10, 'Espadas'); // Sota de espadas
        final falsoPablo = crearCarta(5, 'Copas'); // 5 de copas
        final reyMuestra = crearCarta(12, 'Bastos'); // Rey de bastos, muestra
        final paloMuestra = 'Bastos';

        Baraja.calcularValores(
          [falsaPerica, falsoPablo, reyMuestra],
          paloMuestra,
          'Bastos',
          6,
        );

        // El rey de muestra gana a una sota y un 5 que no son de oros
        expect(reyMuestra.valor, greaterThan(falsaPerica.valor));
        expect(reyMuestra.valor, greaterThan(falsoPablo.valor));
      });
    });

    group('Factory de Reglas', () {
      test('Retorna instancias correctas implícitamente según jugadores', () {
        final tresOros = crearCarta(3, 'Oros');
        final dosOros = crearCarta(2, 'Oros');

        // 2 jugadores: 2 gana a 3 (Jerarquía clásica)
        Baraja.calcularValores([tresOros, dosOros], 'Oros', 'Oros', 2);
        expect(dosOros.valor, greaterThan(tresOros.valor));

        // 4 jugadores: 3 gana a 2 (Andorra > 2)
        Baraja.calcularValores([tresOros, dosOros], 'Oros', 'Oros', 4);
        expect(tresOros.valor, greaterThan(dosOros.valor));

        // Parámetro no estándar (ej. 3) usa default que es 4 jugadores
        Baraja.calcularValores([tresOros, dosOros], 'Oros', 'Oros', 3);
        expect(tresOros.valor, greaterThan(dosOros.valor));
      });
    });

    group('Reglas Personalizadas', () {
      test('Jerarquía personalizada se respeta sobre la por defecto', () {
        final tresOros = crearCarta(3, 'Oros'); // Muestra
        final tuerto = crearCarta(11, 'Oros'); // Tuerto natural
        final dosOros = crearCarta(2, 'Oros'); // Muestra

        // Configuración donde el 3 es lo mejor (rango 1) y el tuerto es rango 2
        final reglasCustom = {'3_muestra': 1, '11_oros': 2, '2_muestra': 3};

        // En 4 jugadores por defecto Tuerto > 3 > 2
        // Pero con custom: 3 > Tuerto > 2
        Baraja.calcularValores(
          [tresOros, tuerto, dosOros],
          'Oros',
          'Oros',
          4,
          reglasCustom,
        );

        expect(tresOros.valor, greaterThan(tuerto.valor));
        expect(tuerto.valor, greaterThan(dosOros.valor));
      });
    });
  });
}
