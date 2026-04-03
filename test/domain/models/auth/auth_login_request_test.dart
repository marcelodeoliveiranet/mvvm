import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';

void main() {
  group('AuthLoginRequest', () {
    test('deve criar instância com email e senha', () {
      final request = AuthLoginRequest(email: 'test@email.com', senha: '123456');

      expect(request.email, 'test@email.com');
      expect(request.senha, '123456');
    });

    test('toJson deve retornar mapa correto', () {
      final request = AuthLoginRequest(email: 'test@email.com', senha: '123456');
      final json = request.toJson();

      expect(json, {'email': 'test@email.com', 'senha': '123456'});
    });

    test('fromJson deve criar instância a partir do mapa', () {
      final json = {'email': 'test@email.com', 'senha': '123456'};
      final request = AuthLoginRequest.fromJson(json);

      expect(request.email, 'test@email.com');
      expect(request.senha, '123456');
    });

    test('toJson e fromJson devem ser simétricos', () {
      final original = AuthLoginRequest(email: 'a@b.com', senha: 'secret');
      final restored = AuthLoginRequest.fromJson(original.toJson());

      expect(restored.email, original.email);
      expect(restored.senha, original.senha);
    });
  });
}
