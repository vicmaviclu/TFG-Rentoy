import 'package:flutter/material.dart';
import '../../../../core/constantes/cadenas.dart';

class WidgetVacio extends StatelessWidget {
  const WidgetVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text(TextoComun.proximamente));
  }
}
