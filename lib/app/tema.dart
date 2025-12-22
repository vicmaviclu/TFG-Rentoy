import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constantes/colores.dart';
import '../core/constantes/textos.dart';

class TemaApp {
  static final ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    // Tema principal
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colores.primario,
      surface: Colores.superficie,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colores.fondo,
    cardColor: Colores.superficie,

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: EstilosTexto.titulo,
        titleLarge: EstilosTexto.subtitulo,
        bodyLarge: EstilosTexto.cuerpo,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colores.secundario,
        foregroundColor: Colores.textoPrimario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colores.textoSecundario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0x22000000)),
      ),
    ),
  );
}
