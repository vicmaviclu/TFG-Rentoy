import 'cadenas.dart';

/// Mapea códigos de error de FirebaseAuth a mensajes amigables para el usuario.
String mensajeErrorFirebaseAuth(String code) {
  switch (code) {
    case 'user-not-found':
    case 'user_not_found':
      return TextoAuth.usuarioNoEncontrado;
    case 'wrong-password':
    case 'wrong_password':
      return TextoAuth.contrasenaIncorrecta;
    case 'invalid-credential':
    case 'invalid_credential':
      return TextoAuth.contrasenaIncorrecta;
    case 'email-already-in-use':
    case 'email_already_in_use':
      return TextoAuth.correoEnUso;
    case 'weak-password':
    case 'weak_password':
      return TextoAuth.contrasenaDebil;
    case 'too-many-requests':
      return TextoAuth.demasiadosIntentos;
    default:
      return TextoComun.errorInesperado; // fallback legible para el usuario
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

class ErroresPartida {
  static const String errorCrear = 'Error creando partida';
}

class ErroresValidacion {
  static const String emailInvalido = 'Correo electrónico inválido';
  static const String contrasenaCorta =
      'La contraseña debe tener al menos 6 caracteres';
  static const String contrasenasNoCoinciden = 'Las contraseñas no coinciden';
  static const String telefonoInvalido = 'Número de teléfono inválido';
}
