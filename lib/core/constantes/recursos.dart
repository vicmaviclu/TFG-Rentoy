class Recursos {
  // Logos y gráficos
  static const String logo = 'assets/images/logo_rentoy.jpg';

  // Iconos vectoriales (si se usan como assets)
  static const String iconoGoogle = 'assets/images/simbolo_google.png';

  static String obtenerAvatar(int index) {
    const int totalAvatares = 12; // Ajustar según disponibilidad real
    // Fallback si el índice está fuera de rango
    if (index < 1 || index > totalAvatares) {
      return 'assets/images/avatares/avatar 1.png';
    }
    return 'assets/images/avatares/avatar $index.png';
  }
}
