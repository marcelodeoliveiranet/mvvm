import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/data/repositories/user/user_repository_impl_remote.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';

import '../../../mocks/mock_user_service.dart';

void main() {
  late MockUserService mockService;
  late UserRepositoryImplRemote repository;

  final user1 = User(id: 1, nome: 'João', email: 'joao@email.com', senha: '123');
  final user2 = User(id: 2, nome: 'Maria', email: 'maria@email.com', senha: '456');

  setUp(() {
    mockService = MockUserService();
    repository = UserRepositoryImplRemote(mockService);
  });

  group('UserRepositoryImplRemote - getAll', () {
    test('deve retornar Ok com lista de usuários no sucesso', () async {
      mockService.getAllResult = [user1, user2];

      final result = await repository.getAll();

      expect(result, isA<Ok<List<User>>>());
      expect((result as Ok<List<User>>).value.length, 2);
    });

    test('deve retornar Ok com lista vazia', () async {
      mockService.getAllResult = [];

      final result = await repository.getAll();

      expect(result, isA<Ok<List<User>>>());
      expect((result as Ok<List<User>>).value, isEmpty);
    });

    test('deve retornar Failure no erro', () async {
      mockService.getAllError = AppException(message: 'Erro ao buscar');

      final result = await repository.getAll();

      expect(result, isA<Failure<List<User>>>());
    });
  });

  group('UserRepositoryImplRemote - getById', () {
    test('deve retornar Ok com usuário no sucesso', () async {
      mockService.getByIdResult = user1;

      final result = await repository.getById(1);

      expect(result, isA<Ok<User>>());
      expect((result as Ok<User>).value.nome, 'João');
    });

    test('deve retornar Failure no erro', () async {
      mockService.getByIdError = AppException(message: 'Não encontrado');

      final result = await repository.getById(999);

      expect(result, isA<Failure<User>>());
    });
  });

  group('UserRepositoryImplRemote - create', () {
    test('deve retornar Ok com usuário criado no sucesso', () async {
      final newUser = User(nome: 'Novo', email: 'novo@email.com', senha: '123456');
      mockService.createResult = User(id: 3, nome: 'Novo', email: 'novo@email.com', senha: '123456');

      final result = await repository.create(newUser);

      expect(result, isA<Ok<User>>());
      expect((result as Ok<User>).value.id, 3);
    });

    test('deve retornar Failure no erro', () async {
      mockService.createError = AppException(message: 'Erro ao criar');

      final result = await repository.create(user1);

      expect(result, isA<Failure<User>>());
    });
  });

  group('UserRepositoryImplRemote - update', () {
    test('deve retornar Ok com usuário atualizado no sucesso', () async {
      final updated = User(id: 1, nome: 'Atualizado', email: 'att@email.com', senha: '123');
      mockService.updateResult = updated;

      final result = await repository.update(updated);

      expect(result, isA<Ok<User>>());
      expect((result as Ok<User>).value.nome, 'Atualizado');
    });

    test('deve retornar Failure no erro', () async {
      mockService.updateError = AppException(message: 'Erro ao atualizar');

      final result = await repository.update(user1);

      expect(result, isA<Failure<User>>());
    });

    test('deve lançar erro se user.id for null (force unwrap)', () async {
      final userSemId = User(nome: 'Sem ID', email: 'sem@email.com', senha: '123');

      final result = await repository.update(userSemId);

      // O force unwrap user.id! causa um TypeError que é capturado pelo catch
      expect(result, isA<Failure<User>>());
    });
  });

  group('UserRepositoryImplRemote - delete', () {
    test('deve retornar Ok no sucesso', () async {
      final result = await repository.delete(1);

      expect(result, isA<Ok<void>>());
    });

    test('deve retornar Failure no erro', () async {
      mockService.deleteError = AppException(message: 'Erro ao deletar');

      final result = await repository.delete(1);

      expect(result, isA<Failure<void>>());
    });
  });
}
