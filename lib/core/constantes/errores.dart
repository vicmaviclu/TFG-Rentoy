import 'cadenas.dart';

/// Mapea códigos de error de FirebaseAuth a mensajes amigables para el usuario.
String mensajeErrorFirebaseAuth(String code) {
  switch (code) {
    case 'user-not-found':
    case 'user_not_found':
      return Cadenas.usuarioNoEncontrado;
    case 'wrong-password':
    case 'wrong_password':
      return Cadenas.contrasenaIncorrecta;
    case 'invalid-credential':
    case 'invalid_credential':
      return Cadenas.contrasenaIncorrecta;
    case 'email-already-in-use':
    case 'email_already_in_use':
      return Cadenas.correoEnUso;
    case 'weak-password':
    case 'weak_password':
      return Cadenas.contrasenaDebil;
    case 'too-many-requests':
      return Cadenas.demasiadosIntentos;
    default:
      return Cadenas.errorInesperado; // fallback legible para el usuario
  }
}
