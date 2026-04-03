import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/user/user.dart';

void main() {
  group('User', () {
    test('deve criar instância com todos os campos', () {
      final user = User(id: 1, nome: 'João', email: 'joao@email.com', senha: '123456');

      expect(user.id, 1);
      expect(user.nome, 'João');
      expect(user.email, 'joao@email.com');
      expect(user.senha, '123456');
    });

    test('deve criar instância com id nulo', () {
      final user = User(nome: 'Maria', email: 'maria@email.com', senha: '654321');

      expect(user.id, isNull);
      expect(user.nome, 'Maria');
    });

    test('toJson deve retornar mapa correto', () {
      final user = User(id: 1, nome: 'João', email: 'joao@email.com', senha: '123456');
      final json = user.toJson();

      expect(json, {
        'id': 1,
        'nome': 'João',
        'email': 'joao@email.com',
        'senha': '123456',
      });
    });

    test('toJson com id nulo deve incluir id como null', () {
      final user = User(nome: 'Maria', email: 'maria@email.com', senha: '654321');
      final json = user.toJson();

      expect(json['id'], isNull);
    });

    test('fromJson deve criar instância a partir do mapa', () {
      final json = {
        'id': 2,
        'nome': 'Carlos',
        'email': 'carlos@email.com',
        'senha': 'abc123',
      };
      final user = User.fromJson(json);

      expect(user.id, 2);
      expect(user.nome, 'Carlos');
      expect(user.email, 'carlos@email.com');
      expect(user.senha, 'abc123');
    });

    test('fromJson com id nulo deve criar instância com id null', () {
      final json = {
        'id': null,
        'nome': 'Ana',
        'email': 'ana@email.com',
        'senha': 'xyz789',
      };
      final user = User.fromJson(json);

      expect(user.id, isNull);
    });

    test('toJson e fromJson devem ser simétricos', () {
      final original = User(id: 5, nome: 'Test', email: 'test@test.com', senha: 'pass');
      final restored = User.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.nome, original.nome);
      expect(restored.email, original.email);
      expect(restored.senha, original.senha);
    });
  });
}
