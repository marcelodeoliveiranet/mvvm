import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/auth/auth_refresh_token.dart';

void main() {
  group('AuthRefreshToken', () {
    test('deve criar instância com refreshToken', () {
      final token = AuthRefreshToken(refreshToken: 'refresh123');

      expect(token.refreshToken, 'refresh123');
    });

    test('toJson deve retornar mapa correto', () {
      final token = AuthRefreshToken(refreshToken: 'refresh123');
      final json = token.toJson();

      expect(json, {'refreshToken': 'refresh123'});
    });

    test('fromJson deve criar instância a partir do mapa', () {
      final json = {'refreshToken': 'refresh123'};
      final token = AuthRefreshToken.fromJson(json);

      expect(token.refreshToken, 'refresh123');
    });

    test('toJson e fromJson devem ser simétricos', () {
      final original = AuthRefreshToken(refreshToken: 'mytoken');
      final restored = AuthRefreshToken.fromJson(original.toJson());

      expect(restored.refreshToken, original.refreshToken);
    });
  });
}
