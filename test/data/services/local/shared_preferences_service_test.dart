import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/services/local/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = SharedPreferencesService(prefs);
  });

  group('SharedPreferencesService', () {
    test('tokens devem ser nulos inicialmente', () {
      expect(service.accessToken, isNull);
      expect(service.refreshToken, isNull);
    });

    test('saveTokens deve salvar access e refresh tokens', () async {
      await service.saveTokens('access123', 'refresh456');

      expect(service.accessToken, 'access123');
      expect(service.refreshToken, 'refresh456');
    });

    test('clear deve remover ambos os tokens', () async {
      await service.saveTokens('access123', 'refresh456');
      await service.clear();

      expect(service.accessToken, isNull);
      expect(service.refreshToken, isNull);
    });

    test('saveTokens deve sobrescrever tokens existentes', () async {
      await service.saveTokens('old_access', 'old_refresh');
      await service.saveTokens('new_access', 'new_refresh');

      expect(service.accessToken, 'new_access');
      expect(service.refreshToken, 'new_refresh');
    });
  });
}
