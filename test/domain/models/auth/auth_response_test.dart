import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';

void main() {
  group('AuthResponse', () {
    test('deve criar instância com accessToken e refreshToken', () {
      final response = AuthResponse(
        accessToken: 'access123',
        refreshToken: 'refresh456',
      );

      expect(response.accessToken, 'access123');
      expect(response.refreshToken, 'refresh456');
    });

    test('toJson deve retornar mapa correto', () {
      final response = AuthResponse(
        accessToken: 'access123',
        refreshToken: 'refresh456',
      );
      final json = response.toJson();

      expect(json, {
        'accessToken': 'access123',
        'refreshToken': 'refresh456',
      });
    });

    test('fromJson deve criar instância a partir do mapa', () {
      final json = {
        'accessToken': 'access123',
        'refreshToken': 'refresh456',
      };
      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'access123');
      expect(response.refreshToken, 'refresh456');
    });

    test('toJson e fromJson devem ser simétricos', () {
      final original = AuthResponse(
        accessToken: 'token1',
        refreshToken: 'token2',
      );
      final restored = AuthResponse.fromJson(original.toJson());

      expect(restored.accessToken, original.accessToken);
      expect(restored.refreshToken, original.refreshToken);
    });
  });
}
