import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentoy/features/auth/controllers/controlador_login.dart';
import 'package:rentoy/features/auth/widgets/formulario_registro.dart';
import 'package:rentoy/core/constantes/cadenas.dart';
import 'package:rentoy/core/constantes/errores.dart';

// Minimal fake UserCredential for tests
class _FakeUserCredential implements UserCredential {
  @override
  User? get user => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
}

void main() {
  group('Tests de ControladorLogin (unidad)', () {
    // Verifica que un email inválido sea detectado y devuelva el mensaje adecuado
    test('inicio con email inválido devuelve Cadenas.emailInvalido', () async {
      final ctrl = ControladorLogin(
        signInWithEmail: (e, p) async =>
            throw FirebaseAuthException(code: 'invalid-email'),
      );

      ctrl.controladorCorreo.text = 'bad-email';
      ctrl.controladorContrasena.text = '123456';

      final res = await ctrl.iniciarSesionConEmail();
      expect(res, ErroresValidacion.emailInvalido);
    });

    // Simula error de contraseña incorrecta y verifica el mapeo a mensaje amigable
    test(
      'inicio con contraseña incorrecta devuelve Cadenas.contrasenaIncorrecta',
      () async {
        final ctrl = ControladorLogin(
          signInWithEmail: (e, p) async =>
              throw FirebaseAuthException(code: 'wrong-password'),
        );

        ctrl.controladorCorreo.text = 'test@example.com';
        ctrl.controladorContrasena.text = 'wrongpass';

        final res = await ctrl.iniciarSesionConEmail();
        expect(res, TextoAuth.contrasenaIncorrecta);
      },
    );

    // Simula intento de registro con contraseña débil (<6) y comprueba el mensaje
    test(
      'registro con contraseña corta devuelve Cadenas.contrasenaCorta',
      () async {
        final ctrl = ControladorLogin(
          createUserWithEmail: (e, p) async =>
              throw FirebaseAuthException(code: 'weak-password'),
        );

        ctrl.controladorCorreo.text = 'test@example.com';
        ctrl.controladorContrasena.text = '123';

        final res = await ctrl.registrarConEmail();
        expect(res, ErroresValidacion.contrasenaCorta);
      },
    );

    // Flujo feliz: registro y login exitosos deben devolver null (sin errores)
    test('registro y login exitosos devuelven null', () async {
      // Provide fake functions that succeed
      final ctrl = ControladorLogin(
        createUserWithEmail: (e, p) async => _FakeUserCredential(),
        signInWithEmail: (e, p) async => _FakeUserCredential(),
      );

      ctrl.controladorCorreo.text = 'ok@example.com';
      ctrl.controladorContrasena.text = 'goodpassword';

      final reg = await ctrl.registrarConEmail();
      expect(reg, isNull);

      final login = await ctrl.iniciarSesionConEmail();
      expect(login, isNull);
    });
  });

  group('Tests de widget para FormularioRegistro', () {
    // Comprueba que si las contraseñas no coinciden se muestra un SnackBar de error
    testWidgets('muestra SnackBar cuando las contraseñas no coinciden', (
      WidgetTester tester,
    ) async {
      final ctrl = ControladorLogin(
        createUserWithEmail: (e, p) async => _FakeUserCredential(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FormularioRegistro(controller: ctrl)),
        ),
      );

      // Enter email
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      // Enter password
      await tester.enterText(find.byType(TextField).at(1), 'password1');
      // Enter different confirm password
      await tester.enterText(find.byType(TextField).at(2), 'password2');

      // Tap register button
      await tester.tap(
        find.widgetWithText(ElevatedButton, TextoAuth.registrarse),
      );
      await tester.pump();

      // Should show a SnackBar with mismatch message
      expect(
        find.text(ErroresValidacion.contrasenasNoCoinciden),
        findsOneWidget,
      );
    });

    // Comprueba que tras un registro exitoso la pantalla se cierra (Navigator.pop)
    testWidgets('registro exitoso provoca Navigator.pop', (
      WidgetTester tester,
    ) async {
      final ctrl = ControladorLogin(
        createUserWithEmail: (e, p) async => _FakeUserCredential(),
      );

      final observer = _PopObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Scaffold(body: FormularioRegistro(controller: ctrl)),
        ),
      );

      // matching passwords
      await tester.enterText(find.byType(TextField).at(0), 'user2@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'goodpassword');
      await tester.enterText(find.byType(TextField).at(2), 'goodpassword');

      await tester.tap(
        find.widgetWithText(ElevatedButton, TextoAuth.registrarse),
      );
      // let async operations complete
      await tester.pumpAndSettle();

      expect(
        observer.didPopCalled,
        isTrue,
        reason: 'Expected the registration flow to pop the route after success',
      );
    });
  });
}

class _PopObserver extends NavigatorObserver {
  bool didPopCalled = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    didPopCalled = true;
    super.didPop(route, previousRoute);
  }
}
