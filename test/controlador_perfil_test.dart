import 'package:flutter_test/flutter_test.dart';
import 'package:rentoy/features/perfil/controllers/controlador_perfil.dart';

class FakeUser {
  final String uid;
  final String email;
  FakeUser(this.uid, this.email);
}

void main() {
  test('avatarSeleccionado clamps values and notifies listeners', () {
    final controller = ControladorPerfil();
    var notified = 0;
    controller.addListener(() => notified++);

    // Setting to below min clamps to 1 but it's already 1, so no notification
    controller.avatarSeleccionado = 0; // below min
    expect(controller.avatarSeleccionado, 1);
    expect(notified, 0);

    // Setting to a different valid value should notify
    controller.avatarSeleccionado = 5;
    expect(controller.avatarSeleccionado, 5);
    expect(notified, 1);

    // Setting above max clamps to 9 and notifies because value changed
    controller.avatarSeleccionado = 20; // above max
    expect(controller.avatarSeleccionado, 9);
    expect(notified, 2);

    controller.dispose();
  });

  test('guardarPerfil returns No autenticado when no user', () async {
    final controller = ControladorPerfil(userProvider: () => null);
    final res = await controller.guardarPerfil();
    expect(res, 'No autenticado');
  });

  test('guardarPerfil returns validation message when username empty', () async {
    final controller = ControladorPerfil(userProvider: () => FakeUser('u1', 'a@b.c'));
    controller.controladorNombreUsuario.text = '';
    final res = await controller.guardarPerfil();
    expect(res, 'Introduce un nombre de usuario');
  });
}
