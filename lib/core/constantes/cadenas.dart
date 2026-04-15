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
  static const String funcionalidadPendiente = 'Funcionalidad próximamente';
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

  // Mensajes de navegación auth
  static const String noTienesCuenta = '¿No tienes cuenta? Regístrate';
  static const String yaTienesCuenta = '¿Ya tienes cuenta? Inicia sesión';
  static const String registroCompletado = 'Registro completado';
  static const String introducirUsuario = 'Introduce un nombre de usuario';
  static const String usuarioEnUso = 'El nombre de usuario ya está en uso';
}

/// Textos relacionados con la partida (Crear, Unirse, Sala de espera).
class TextoPartida {
  // Acciones principales
  static const String iniciarPartida = 'Iniciar partida';
  static const String btnCrearPartida = 'Crear Partida';
  static const String btnUnirsePartida = 'Unirse a Partida';
  static const String btnReglasJuego = 'Reglas del Juego';
  static const String btnBuscar = 'Buscar';
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
  static const String estadoJugando = 'jugando';

  // Mesa
  static const String mesaDeJuego = 'Mesa de Juego';
  static const String ganando = 'Ganando: ';
  static const String btnLanzar = 'LANZAR';

  // Fin de partida
  static const String victoria = '¡VICTORIA!';
  static const String derrota = 'DERROTA';
  static const String volverAlMenu = 'Volver al Menú';
  static const String objetivo = 'Objetivo';
  static const String puntos = 'pts';
  static const String cantar = 'Cantar';
  static const String cambiar = 'Cambiar';
  static const String muestra = 'Muestra';
  static const String ronda = 'Ronda';

  // Envites
  static const String envitePendientePrecaucion = 'Ya hay un envite pendiente.';
  static const String errorTurnoCantar = 'Solo puedes cantar en tu turno.';
  static const String errorEquipoYaCanto =
      'Tu equipo ya cantó. Debes esperar a que el rival cante.';
  static const String enviteEnviado = 'Envite enviado.';
  static const String tituloEnvite = '¡TE HAN CANTADO!';
  static const String enviteSubeA = 'La ronda sube a ';
  static const String btnReenviar = 'Reenviar';
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
  static const String jugadorDefecto = 'Jugador';
}

/// Textos legales y ayuda.
class TextoAyuda {
  static const String ayuda = 'Ayuda';
  static const String terminos = 'Términos y condiciones';
  static const String politicaPrivacidad = 'Política de privacidad';
}

/// Textos de reglas del juego
class TextoReglas {
  static const String tituloOverlay = '¿Cómo jugar al Rentoy?';
  static const String btnSiguiente = 'Siguiente';
  static const String btnAnterior = 'Anterior';
  static const String btnCerrar = '¡Entendido!';

  static const String pagina1Titulo = '1. El Objetivo';
  static const String pagina1Contenido =
      'El Rentoy se juega por **equipos**. El objetivo es alcanzar la puntuación límite antes que el rival (por ejemplo, **21 puntos**).\n\n'
      'Ganas puntos al vencer en las **"Rondas"**. Empezáis la ronda jugando por **1 punto**, pero la puntuación puede subir si alguien decide **"Cantar"**.';

  static const String pagina2Titulo = '2. Las Bazas';
  static const String pagina2Contenido =
      'Una ronda está compuesta por pequeñas batallas llamadas **"Bazas"** (indicadas por círculos).\n\n'
      'En cada baza, todos los jugadores tiran una carta en su turno. El que tire la **carta más fuerte** gana esa baza para su equipo. '
      'La ronda se juega al **mejor de tres bazas**; el primer equipo en conseguir ganar **2 bazas**, gana la ronda.';

  static const String pagina3Titulo = '3. La Muestra y El Arrastre';
  static const String pagina3Contenido =
      'Al repartir se descubre una carta central: **"La Muestra"**. Las cartas de este palo **valen más que cualquier otro palo**, menos las cartas especiales.\n\n'
      '**Arrastre**: Si la primera persona que empieza una baza lanza una carta de la Muestra, los demás están **obligados** a echar una si tienen. Si se lanza cualquier otro palo inicial, **no hay arrastre** y puedes lanzar lo que más te convenga.';

  static const String pagina4Titulo = '4. Cantar (El Envite)';
  static const String pagina4Contenido =
      'Esta es la salsa del juego. Antes de echar tu carta, puedes **"Cantar"** para apostar más puntos.\n\n'
      'El rival debe decidir: si **acepta**, la ronda vale más. Si **rechaza**, pierden la ronda inmediatamente. '
      '¡También pueden subir la apuesta (**Re-envite**)!';

  static const String pagina5Titulo = '5. La Jerarquía (Orden de Fuerza)';
  static const String pagina5Contenido =
      'Para decidir la carta ganadora de la baza sigue este orden:\n\n'
      '**1º. Cartas Especiales** (van primero).\n'
      '**2º. Cartas de la Muestra** (Orden: 2, 12, 11, 10, 1, 7, 6, 5, 4, 3).\n'
      '**3º.** Si no hay carta de Muestra, la baza del primer jugador (**Palo de Salida**) será lo que más vale (Orden: 12, 11, 10, 1, 7, 6, 5, 4, 3, 2).';

  static const String pagina6Titulo = '6. Cartas Especiales';
  static const String pagina6Contenido =
      'Dependiendo de si sois 4 o 6 jugadores, algunas cartas de Oros se transforman en **especiales** (van primero en la jerarquía):\n\n'
      '• **4 Jugadores**: El **"Tuerto"** (11 de Oros).\n'
      '• **6 Jugadores**: Existen 3 especiales en este orden: 1º **"Perica"** (10 de Oros), 2º **"Pablo"** (5 de Oros), y 3º el **"Tuerto"** (11 de Oros).';
}
