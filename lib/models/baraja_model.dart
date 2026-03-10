import 'dart:math';
import 'carta_model.dart';
import 'reglas_juego_model.dart';

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

        final valor =
            0; // Inicialmente 0, se calcula dinámicamente según reglas
        final path = _obtenerRutaImagen(palo, prefijo, i);

        cartas.add(Carta(numero: i, palo: palo, valor: valor, foto: path));
      }
    }
  }

  /// Calcula y asigna los valores a una lista de cartas según las reglas actuales.
  /// [cartas]: Lista de cartas a actualizar.
  /// [paloMuestra]: Palo del triunfo.
  /// [paloSalida]: Palo de salida de la baza actual.
  /// [cantidadJugadores]: Para saber qué reglas aplicar (2, 4, 6).
  /// [reglasPersonalizadas]: Mapa con la jerarquía personalizada de cartas especiales.
  static void calcularValores(
    List<Carta> cartas,
    String paloMuestra,
    String? paloSalida,
    int cantidadJugadores, [
    Map<String, int>? reglasPersonalizadas,
  ]) {
    final reglas = ReglasFactory.obtenerReglas(
      cantidadJugadores,
      reglasPersonalizadas,
    );

    for (var carta in cartas) {
      carta.valor = reglas.calcularFuerza(carta, paloMuestra, paloSalida);
    }
  }

  /// Reinicia el valor de todas las cartas a 0.
  static void resetearValores(List<Carta> cartas) {
    for (var carta in cartas) {
      carta.valor = 0;
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
