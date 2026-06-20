import 'package:flutter/material.dart';
import 'colores.dart';

class EstilosTexto {
  // Estilo para títulos grandes
  static const TextStyle tituloGrande = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colores.textoPrimario,
    fontFamily: 'Inter',
  );

  // Estilo para títulos medios
  static const TextStyle tituloMedio = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colores.textoPrimario,
    fontFamily: 'Inter',
  );

  static const TextStyle titulo = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colores.textoPrimario,
  );

  static const TextStyle subtitulo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colores.textoSecundario,
  );

  static const TextStyle cuerpo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colores.textoPrimario,
  );

  static const TextStyle cuerpoNegrita = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colores.textoSecundario,
  );

  static const TextStyle boton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colores.textoPrimario,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colores.textoSecundario,
  );

  static const TextStyle tituloPequeno = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colores.textoPrimario,
  );

  static const TextStyle cuerpoPequeno = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colores.textoPrimario,
  );
}
