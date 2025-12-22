/// Textos generales y comunes de la aplicación.
class TextoComun {
  // App
  static const String nombreApp = 'Pocket Rentoy';
  static const String subtitulo = 'Juega, diviértete y conecta';

  // Mensajes generales / estados
  static const String cargando = 'Cargando...';
  static const String errorInesperado = 'Error inesperado';
  static const String sinConexion = 'Sin conexión a internet';
  static const String reintentar = 'Reintentar';
  static const String accionExitosa = 'Acción completada con éxito';
  static const String campoRequerido = 'Este campo es obligatorio';
  static const String proximamente = 'Contenido próximamente';

  // Botones y acciones generales
  static const String aceptar = 'Aceptar';
  static const String cancelar = 'Cancelar';
  static const String si = 'Sí';
  static const String no = 'No';
  static const String guardar = 'Guardar';
  static const String editar = 'Editar';
  static const String continuar = 'Continuar';
  static const String confirmar = 'Confirmar';
  static const String volver = 'Volver';
  static const String cerrarSesion = 'Cerrar sesión';

  // Ajustes y navegación
  static const String ajustes = 'Ajustes';
  static const String idioma = 'Idioma';
  static const String notificaciones = 'Notificaciones';
}

/// Textos relacionados con la autenticación (Login, Registro).
class TextoAuth {
  // Títulos
  static const String tituloLogin = 'Inicia sesión';
  static const String tituloRegistro = 'Regístrate';

  // Campos y Placeholders
  static const String correoHint = 'Correo electrónico';
  static const String contrasenaHint = 'Contraseña';
  static const String confirmarContrasena = 'Confirmar contraseña';

  // Botones y acciones
  static const String continuarConGoogle = 'Continuar con Google';
  static const String crearCuenta = 'Crear cuenta';
  static const String registrarse = 'Registrarse';
  static const String iniciando = 'Iniciando...';
  static const String bienvenido = 'Bienvenido';

  // Mensajes de error Auth
  static const String usuarioNoEncontrado = 'Usuario no encontrado';
  static const String contrasenaIncorrecta = 'Contraseña incorrecta';
  static const String correoEnUso = 'El correo ya está en uso';
  static const String contrasenaDebil = 'Contraseña demasiado débil';
  static const String demasiadosIntentos =
      'Demasiados intentos, inténtalo más tarde';

  // Mensajes de navegación auth
  static const String noTienesCuenta = '¿No tienes cuenta? Regístrate';
  static const String yaTienesCuenta = '¿Ya tienes cuenta? Inicia sesión';
  static const String registroCompletado = 'Registro completado';
}

/// Textos relacionados con la partida (Crear, Unirse, Sala de espera).
class TextoPartida {
  // Acciones principales
  static const String iniciarPartida = 'Iniciar partida';
  static const String btnCrearPartida = 'Crear Partida';
  static const String btnUnirsePartida = 'Unirse a Partida';
  static const String empezarPartida = 'Empezar';

  // Títulos de pantalla
  static const String tituloCrearPartida = 'Crear Partida';
  static const String tituloUnirsePartida = 'Unirse a Partida';
  static const String salaEspera = 'Sala de espera';

  // Sala de espera / info
  static const String anfitrion = 'Anfitrión';
  static const String idLabel = 'ID:';
  static const String idCopiado = 'ID copiado al portapapeles';
  static const String pinCopiado = 'PIN copiado al portapapeles';
  static const String esperandoDatos = 'Esperando datos...';
  static const String invitarJugadores = 'Invitar';
  static const String esperando = 'Esperando...';
  static const String numeroJugadores = 'Número de jugadores';
  static const String introducePin = 'Introduce el PIN de la partida';
  static const String equipo1 = 'Equipo 1';
  static const String equipo2 = 'Equipo 2';
  static const String cancelarPartida = 'Cancelar partida';
  static const String confirmarCancelarPartida =
      'Si sales, la partida se eliminará. ¿Continuar?';
}

/// Textos relacionados con el perfil de usuario.
class TextoPerfil {
  static const String perfil = 'Perfil';
  static const String avatar = 'Avatar';
  static const String guardarCambios = 'Guardar cambios';
  static const String privacidad = 'Privacidad';
  static const String correoNoEditable = 'El correo no puede modificarse aquí';

  // Campos de perfil
  static const String nombre = 'Nombre';
  static const String nombreUsuario = 'Nombre de usuario';
  static const String apellidos = 'Apellidos';
  static const String telefono = 'Teléfono';
  static const String direccion = 'Dirección';
  static const String fechaNacimiento = 'Fecha de nacimiento';
  static const String siguienteAvatar = 'Siguiente avatar';
}

/// Textos legales y ayuda.
class TextoAyuda {
  static const String ayuda = 'Ayuda';
  static const String terminos = 'Términos y condiciones';
  static const String politicaPrivacidad = 'Política de privacidad';
}
