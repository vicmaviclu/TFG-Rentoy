class Recursos {
  // Logos y gráficos
  static const String logo = 'assets/images/logo_rentoy.jpg';

  // Iconos
  static const String iconoGoogle = 'assets/images/simbolo_google.png';

  static String obtenerAvatar(int index) {
    const int totalAvatares = 4;
    // Fallback si el índice está fuera de rango
    if (index < 1 || index > totalAvatares) {
      return 'assets/images/avatares/avatar 1.png';
    }
    return 'assets/images/avatares/avatar $index.png';
  }

  static String obtenerCarta(String palo, dynamic numero) {
    if (palo.isEmpty) return '';
    final numStr = numero.toString();
    if (numStr == '0') return '';

    final prefijo = palo[0];
    return 'assets/images/cartas/${palo.toLowerCase()}/$prefijo$numStr.png';
  }
}
