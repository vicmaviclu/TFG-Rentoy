import '../../../models/carta_model.dart';

/// Define la estrategia para las reglas del juego.
/// Permite variar la jerarquía de cartas según el número de jugadores (2, 4, 6).
abstract class ReglasJuego {
  /// Jerarquía de cartas para el palo de triunfo (Muestra).
  /// De mayor a menor fuerza.
  static const List<int> _jerarquiaTriunfo = [2, 12, 11, 10, 1, 7, 6, 5, 4, 3];

  /// Jerarquía de cartas para palos normales (No Muestra).
  /// De mayor a menor fuerza.
  static const List<int> _jerarquiaNormal = [12, 11, 10, 1, 7, 6, 5, 4, 3, 2];

  /// Calcula la fuerza de una carta dada.
  ///
  /// [carta]: La carta a evaluar.
  /// [paloMuestra]: El palo del triunfo.
  /// [paloSalida]: El palo de la primera carta jugada en la baza (null si es la primera).
  ///
  /// Retorna un valor entero representando la fuerza relativa.
  /// Mayor valor gana la baza.
  int calcularFuerza(Carta carta, String paloMuestra, String? paloSalida) {
    bool esTriunfo = carta.palo.toLowerCase() == paloMuestra.toLowerCase();
    bool esPaloSalida =
        paloSalida != null &&
        carta.palo.toLowerCase() == paloSalida.toLowerCase();

    // Base de puntos para separar categorías:
    // Triunfos: 200+
    // Palo Salida: 100+
    // Resto: 0+
    int baseScore = 0;

    if (esTriunfo) {
      baseScore = 200;
    } else if (esPaloSalida) {
      baseScore = 100;
    } else {
      baseScore = 0;
    }

    int rankScore = _obtenerPuntajeRanking(carta.numero, esTriunfo);

    return baseScore + rankScore;
  }

  /// Obtiene el puntaje por ranking (posición en la jerarquía)
  int _obtenerPuntajeRanking(int numero, bool esTriunfo) {
    List<int> jerarquia = esTriunfo ? _jerarquiaTriunfo : _jerarquiaNormal;

    // Buscamos el índice. Mientras menor sea el índice, mayor es la carta.
    // Invertimos el valor para que un índice bajo de un puntaje alto.
    // jerarquia.length = 10. Indice 0 (el mejor) -> 10 puntos. Indice 9 -> 1 punto.
    int index = jerarquia.indexOf(numero);

    if (index == -1) {
      return 0; // Carta no encontrada en jerarquía estándar (error?)
    }

    return jerarquia.length - index;
  }

  // --- MÉTODOS QUE PUEDEN SER SOBREESCRITOS POR ESTRATEGIAS ESPECÍFICAS ---

}

/// Reglas para 2 jugadores.
class ReglasDosJugadores extends ReglasJuego {}

/// Reglas para 4 jugadores.
class ReglasCuatroJugadores extends ReglasJuego {}

/// Reglas para 6 jugadores.
class ReglasSeisJugadores extends ReglasJuego {}

/// Factory para obtener la regla correcta.
class ReglasFactory {
  static ReglasJuego obtenerReglas(int cantidadJugadores) {
    switch (cantidadJugadores) {
      case 2:
        return ReglasDosJugadores();
      case 6:
        return ReglasSeisJugadores();
      case 4:
      default:
        // Default a 4 si no coincide o es otro número
        return ReglasCuatroJugadores();
    }
  }
}
