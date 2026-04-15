import 'cadenas.dart';

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

  static const List<Map<String, String>> paginasDeReglas = [
    {
      'titulo': TextoReglas.pagina1Titulo,
      'contenido': TextoReglas.pagina1Contenido,
      'imagen': 'assets/images/reglas/puntuacion-total.png',
    },
    {
      'titulo': TextoReglas.pagina2Titulo,
      'contenido': TextoReglas.pagina2Contenido,
      'imagen': 'assets/images/reglas/puntuacion-0.png',
    },
    {
      'titulo': TextoReglas.pagina3Titulo,
      'contenido': TextoReglas.pagina3Contenido,
      'imagen': 'assets/images/reglas/arrastre.png',
    },
    {
      'titulo': TextoReglas.pagina4Titulo,
      'contenido': TextoReglas.pagina4Contenido,
      'imagen': 'assets/images/reglas/envio.png',
    },
    {
      'titulo': TextoReglas.pagina5Titulo,
      'contenido': TextoReglas.pagina5Contenido,
      'imagen': 'assets/images/reglas/muestra.png',
    },
    {
      'titulo': TextoReglas.pagina6Titulo,
      'contenido': TextoReglas.pagina6Contenido,
    },
  ];
}
