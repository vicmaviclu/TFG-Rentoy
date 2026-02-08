class Carta {
  final int numero;
  final String palo;
  final int valor;
  final String foto;
  bool usada;

  Carta({
    required this.numero,
    required this.palo,
    required this.valor,
    required this.foto,
    this.usada = false,
  });

  Map<String, dynamic> toMap() {
    return {'numero': numero, 'palo': palo, 'usada': usada};
  }

  factory Carta.fromMap(Map<String, dynamic> map) {
    final int numero = (map['numero'] is int)
        ? map['numero'] as int
        : int.tryParse(map['numero']?.toString() ?? '0') ?? 0;

    final String palo = map['palo']?.toString() ?? '';
    final bool usada = map['usada'] == true;

    // Reconstruir valor
    int valor = 0;
    if (numero == 1) {
      valor = 11;
    } else if (numero == 3) {
      valor = 10;
    } else if (numero == 12) {
      valor = 4;
    } else if (numero == 11) {
      valor = 3;
    } else if (numero == 10) {
      valor = 2;
    }

    // Reconstruir foto (todos png)
    final prefijo = palo.isNotEmpty ? palo[0] : '';
    final foto =
        'Assets/images/cartas/${palo.toLowerCase()}/$prefijo$numero.png';

    return Carta(
      numero: numero,
      palo: palo,
      valor: valor,
      foto: foto,
      usada: usada,
    );
  }
}
