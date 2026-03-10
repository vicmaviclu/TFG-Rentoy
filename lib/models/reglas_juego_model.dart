import '../../../models/carta_model.dart';

/// Define la estrategia para las reglas del juego.
/// Permite variar la jerarquía de cartas según el número de jugadores (2, 4, 6).
abstract class ReglasJuego {
  /// Jerarquía de cartas para el palo de triunfo (Muestra).
  /// De mayor a menor fuerza. (Por defecto 2 jugadores)
  List<int> get jerarquiaTriunfo => [2, 12, 11, 10, 1, 7, 6, 5, 4, 3];

  /// Jerarquía de cartas para palos normales (No Muestra).
  /// De mayor a menor fuerza.
  List<int> get jerarquiaNormal => [12, 11, 10, 1, 7, 6, 5, 4, 3, 2];

  /// Retorna la fuerza adicional o null si no es especial.
  int? getFuerzaCartaEspecial(Carta carta, String paloMuestra) {
    return null; // Por defecto no hay cartas especiales (2 jugadores)
  }

  /// Calcula la fuerza de una carta dada.
  ///
  /// [carta]: La carta a evaluar.
  /// [paloMuestra]: El palo del triunfo.
  /// [paloSalida]: El palo de la primera carta jugada en la baza (null si es la primera).
  ///
  /// Retorna un valor entero representando la fuerza relativa.
  /// Mayor valor gana la baza.
  int calcularFuerza(Carta carta, String paloMuestra, String? paloSalida) {
    // Si la carta es especial (tuerto, malilla, perica, pablo), retorna su fuerza especial asegurando que gane a todos
    int? fuerzaEspecial = getFuerzaCartaEspecial(carta, paloMuestra);
    if (fuerzaEspecial != null) {
      return 300 + fuerzaEspecial;
    }

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
    List<int> jerarquia = esTriunfo ? jerarquiaTriunfo : jerarquiaNormal;

    // Buscamos el índice. Mientras menor sea el índice, mayor es la carta.
    // Invertimos el valor para que un índice bajo de un puntaje alto.
    // jerarquia.length = 10. Indice 0 (el mejor) -> 10 puntos. Indice 9 -> 1 punto.
    int index = jerarquia.indexOf(numero);

    if (index == -1) {
      return 0; // Carta no encontrada en jerarquía estándar (error?)
    }

    return jerarquia.length - index;
  }
}

/// Reglas para 2 jugadores.
class ReglasDosJugadores extends ReglasJuego {}

/// Reglas para 4 jugadores.
class ReglasCuatroJugadores extends ReglasJuego {
  @override
  List<int> get jerarquiaTriunfo => [3, 2, 12, 11, 10, 1, 7, 6, 5, 4];

  @override
  int? getFuerzaCartaEspecial(Carta carta, String paloMuestra) {
    // El 11 de Oros (Tuerto) es la mejor carta absoluta.
    if (carta.numero == 11 && carta.palo.toLowerCase() == 'oros') {
      return 100; // Total: 400
    }
    return null;
  }
}

/// Reglas para 6 jugadores.
class ReglasSeisJugadores extends ReglasCuatroJugadores {
  @override
  int? getFuerzaCartaEspecial(Carta carta, String paloMuestra) {
    // 10 de Oros (Perica) es la mejor
    if (carta.numero == 10 && carta.palo.toLowerCase() == 'oros') {
      return 100; // Total: 400
    }
    // 5 de Oros (Pablo) es la segunda mejor
    if (carta.numero == 5 && carta.palo.toLowerCase() == 'oros') {
      return 90; // Total: 390
    }
    // 11 de Oros (Tuerto) es la tercera mejor
    if (carta.numero == 11 && carta.palo.toLowerCase() == 'oros') {
      return 80; // Total: 380
    }
    return null;
  }
}

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
