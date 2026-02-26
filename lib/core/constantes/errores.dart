import 'cadenas.dart';

/// Errores de autenticación de Firebase.
class ErroresAuth {
  static const String usuarioNoEncontrado = 'Usuario no encontrado';
  static const String contrasenaIncorrecta = 'Contraseña incorrecta';
  static const String correoEnUso = 'El correo ya está en uso';
  static const String contrasenaDebil = 'Contraseña demasiado débil';
  static const String demasiadosIntentos =
      'Demasiados intentos, inténtalo más tarde';
}

/// Mapea códigos de error de FirebaseAuth a mensajes amigables para el usuario.
String mensajeErrorFirebaseAuth(String code) {
  switch (code) {
    case 'user-not-found':
    case 'user_not_found':
      return ErroresAuth.usuarioNoEncontrado;
    case 'wrong-password':
    case 'wrong_password':
      return ErroresAuth.contrasenaIncorrecta;
    case 'invalid-credential':
    case 'invalid_credential':
      return ErroresAuth.contrasenaIncorrecta;
    case 'email-already-in-use':
    case 'email_already_in_use':
      return ErroresAuth.correoEnUso;
    case 'weak-password':
    case 'weak_password':
      return ErroresAuth.contrasenaDebil;
    case 'too-many-requests':
      return ErroresAuth.demasiadosIntentos;
    default:
      return TextoComun.errorInesperado;
  }
}

/// Errores específicos de la gestión de perfil.
class ErroresPerfil {
  static const String noAutenticado = 'No autenticado';
  static const String nombreUsuarioVacio = 'Introduce un nombre de usuario';
  static const String nombreUsuarioEnUso =
      'El nombre de usuario ya está en uso';
  static const String permisoInsuficiente =
      'Permisos insuficientes para guardar el perfil';
  static const String requiereReautenticacion =
      'Operación requiere inicio de sesión reciente';
  static const String errorFirebaseDesconocido = 'Error al acceder a Firebase';
}

class ErroresRed {
  static const String tiempoAgotado =
      'Tiempo de espera agotado. Comprueba tu conexión a internet.';
}

/// Errores de lógica de juego durante la partida.
class ErroresPartida {
  static const String errorCrear = 'Error creando partida';
  static const String noEsTuTurno = 'No es tu turno';
  static const String rondaNoActiva = 'No hay ronda activa';
  static const String cartaNoValida = 'Carta no válida o índice incorrecto';
  static const String jugadorNoEncontrado =
      'No se encontró el jugador actual en la partida';
  static const String errorLanzarCarta = 'Error al lanzar carta: ';
  static const String errorSesionInfo =
      'No se pudo obtener información de la sesión';
  static const String errorCantar = 'Error al cantar: ';
}

class ErroresValidacion {
  static const String emailInvalido = 'Correo electrónico inválido';
  static const String contrasenaCorta =
      'La contraseña debe tener al menos 6 caracteres';
  static const String contrasenasNoCoinciden = 'Las contraseñas no coinciden';
  static const String telefonoInvalido = 'Número de teléfono inválido';
}

/// Errores de sesión y partidas en tiempo real.
class ErroresSesion {
  static const String autenticacionRequerida = 'Autenticación requerida.';
  static const String autenticacionCrearPartida =
      'Autenticación requerida. Inicia sesión para crear una partida.';
  static const String autenticacionUnirsePartida =
      'Autenticación requerida. Inicia sesión para unirte a una partida.';
  static const String sesionNoEncontrada = 'Sesión no encontrada';
  static const String salaLlena = 'La sala está llena';
  static const String huecoOcupado = 'El hueco ya está ocupado';
  static const String pinNoEncontrado =
      'No se encontró ninguna partida con ese PIN.';
}
