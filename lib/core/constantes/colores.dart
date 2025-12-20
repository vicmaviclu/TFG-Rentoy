import 'package:flutter/material.dart';

class Colores {
  static const Color primario = Color(0xFF2E8B57); // más cercano al degradado verde
  // Variante semitransparente del color primario para overlays y tarjetas
  static const Color primarioTransparente = Color(0xAA2E8B57);
  static const Color secundario = Color(0xFFFFC107);
  // Colores para textos sobre fondos oscuros/primario
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color blanco70 = Color.fromRGBO(255, 255, 255, 0.70);
  static const Color blanco24 = Color.fromRGBO(255, 255, 255, 0.24);
  static const Color blanco12 = Color.fromRGBO(255, 255, 255, 0.12);
  static const Color blanco08 = Color.fromRGBO(255, 255, 255, 0.08);
  // Sombras / negros semitransparentes
  static const Color negro12 = Color.fromRGBO(0, 0, 0, 0.12);
  // Transparent helper
  static const Color transparente = Color.fromRGBO(0, 0, 0, 0);
  // Fondo general: un verde muy claro para que la 'tarjeta' no se vea blanca
  static const Color fondo = Color.fromARGB(255, 124, 207, 160);
  // Superficie clara (si hace falta usar blanco para elementos puntuales)
  static const Color superficie = Color(0xFFF7FFF9);
  static const Color tarjeta = Color(0xFF0F1724);
  static const Color textoPrimario = Color(0xFF0B1020);
  static const Color textoSecundario = Color.fromARGB(255, 42, 43, 45);
  static const Color acento = Color(0xFF00C853);
  static const Color grisGoogle = Color(0xFFF1F3F4);
}
