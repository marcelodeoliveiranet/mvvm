import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/utils/result.dart';

import '../../../mocks/mock_user_repository.dart';

void main() {
  late MockUserRepository mockRepository;
  late UserViewModel viewModel;

  final user1 = User(id: 1, nome: 'João', email: 'joao@email.com', senha: '123');
  final user2 = User(id: 2, nome: 'Maria', email: 'maria@email.com', senha: '456');

  setUp(() {
    mockRepository = MockUserRepository();
    viewModel = UserViewModel(userRepository: mockRepository);
  });

  group('UserViewModel - estado inicial', () {
    test('users deve ser lista vazia inicialmente', () {
      expect(viewModel.users, isEmpty);
    });

    test('todos os commands devem existir', () {
      expect(viewModel.loadUsersCommand, isNotNull);
      expect(viewModel.getUserByIdCommand, isNotNull);
      expect(viewModel.createUserCommand, isNotNull);
      expect(viewModel.updateUserCommand, isNotNull);
      expect(viewModel.deleteUserCommand, isNotNull);
    });
  });

  group('UserViewModel - loadUsers', () {
    test('deve atualizar lista de users no sucesso', () async {
      mockRepository.getAllResult = Result.ok([user1, user2]);

      final result = await viewModel.loadUsers();

      expect(result, isA<Ok<List<User>>>());
      expect(viewModel.users.length, 2);
      expect(viewModel.users[0].nome, 'João');
    });

    test('deve retornar Failure no erro sem alterar lista', () async {
      mockRepository.getAllResult = Result.error(Exception('erro'));

      final result = await viewModel.loadUsers();

      expect(result, isA<Failure>());
      expect(viewModel.users, isEmpty);
    });

    test('deve notificar listeners no sucesso', () async {
      mockRepository.getAllResult = Result.ok([user1]);
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.loadUsers();

      expect(notified, true);
    });
  });

  group('UserViewModel - getUserById', () {
    test('deve retornar Ok com usuário no sucesso', () async {
      mockRepository.getByIdResult = Result.ok(user1);

      final result = await viewModel.getUserById(1);

      expect(result, isA<Ok<User>>());
      expect((result as Ok<User>).value.nome, 'João');
    });

    test('deve retornar Failure no erro', () async {
      mockRepository.getByIdResult = Result.error(Exception('não encontrado'));

      final result = await viewModel.getUserById(999);

      expect(result, isA<Failure>());
    });
  });

  group('UserViewModel - createUser', () {
    test('deve adicionar usuário à lista no sucesso', () async {
      final newUser = User(id: 3, nome: 'Carlos', email: 'carlos@email.com', senha: '789');
      mockRepository.createResult = Result.ok(newUser);

      final result = await viewModel.createUser(newUser);

      expect(result, isA<Ok<User>>());
      expect(viewModel.users.length, 1);
      expect(viewModel.users[0].nome, 'Carlos');
    });

    test('não deve alterar lista no erro', () async {
      mockRepository.createResult = Result.error(Exception('erro'));

      await viewModel.createUser(user1);

      expect(viewModel.users, isEmpty);
    });

    test('deve notificar listeners no sucesso', () async {
      mockRepository.createResult = Result.ok(user1);
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.createUser(user1);

      expect(notified, true);
    });
  });

  group('UserViewModel - updateUser', () {
    test('deve atualizar usuário na lista no sucesso', () async {
      // Popula a lista primeiro
      mockRepository.getAllResult = Result.ok([user1, user2]);
      await viewModel.loadUsers();

      final updated = User(id: 1, nome: 'João Atualizado', email: 'joao@email.com', senha: '123');
      mockRepository.updateResult = Result.ok(updated);

      final result = await viewModel.updateUser(updated);

      expect(result, isA<Ok<User>>());
      expect(viewModel.users.firstWhere((u) => u.id == 1).nome, 'João Atualizado');
      expect(viewModel.users.length, 2); // Tamanho não muda
    });

    test('deve notificar listeners mesmo se usuário não existe na lista', () async {
      final updated = User(id: 99, nome: 'Inexistente', email: 'x@x.com', senha: '123');
      mockRepository.updateResult = Result.ok(updated);
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.updateUser(updated);

      expect(notified, true);
    });

    test('não deve alterar lista no erro', () async {
      mockRepository.getAllResult = Result.ok([user1]);
      await viewModel.loadUsers();

      mockRepository.updateResult = Result.error(Exception('erro'));

      await viewModel.updateUser(user1);

      expect(viewModel.users.length, 1);
      expect(viewModel.users[0].nome, 'João');
    });
  });

  group('UserViewModel - deleteUser', () {
    test('deve remover usuário da lista no sucesso', () async {
      mockRepository.getAllResult = Result.ok([user1, user2]);
      await viewModel.loadUsers();
      expect(viewModel.users.length, 2);

      mockRepository.deleteResult = Result.ok(null);

      final result = await viewModel.deleteUser(1);

      expect(result, isA<Ok<void>>());
      expect(viewModel.users.length, 1);
      expect(viewModel.users[0].nome, 'Maria');
    });

    test('não deve alterar lista no erro', () async {
      mockRepository.getAllResult = Result.ok([user1]);
      await viewModel.loadUsers();

      mockRepository.deleteResult = Result.error(Exception('erro'));

      await viewModel.deleteUser(1);

      expect(viewModel.users.length, 1);
    });

    test('deve notificar listeners no sucesso', () async {
      mockRepository.getAllResult = Result.ok([user1]);
      await viewModel.loadUsers();

      mockRepository.deleteResult = Result.ok(null);
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.deleteUser(1);

      expect(notified, true);
    });
  });

  group('UserViewModel - commands executam corretamente', () {
    test('loadUsersCommand deve atualizar estado', () async {
      mockRepository.getAllResult = Result.ok([user1]);

      await viewModel.loadUsersCommand.execute();

      expect(viewModel.loadUsersCommand.completed, true);
      expect(viewModel.users.length, 1);
    });

    test('createUserCommand deve atualizar estado', () async {
      mockRepository.createResult = Result.ok(user1);

      await viewModel.createUserCommand.execute(user1);

      expect(viewModel.createUserCommand.completed, true);
    });

    test('updateUserCommand deve atualizar estado', () async {
      mockRepository.updateResult = Result.ok(user1);

      await viewModel.updateUserCommand.execute(user1);

      expect(viewModel.updateUserCommand.completed, true);
    });

    test('deleteUserCommand deve atualizar estado', () async {
      mockRepository.getAllResult = Result.ok([user1]);
      await viewModel.loadUsers();

      mockRepository.deleteResult = Result.ok(null);

      await viewModel.deleteUserCommand.execute(1);

      expect(viewModel.deleteUserCommand.completed, true);
    });

    test('getUserByIdCommand deve atualizar estado', () async {
      mockRepository.getByIdResult = Result.ok(user1);

      await viewModel.getUserByIdCommand.execute(1);

      expect(viewModel.getUserByIdCommand.completed, true);
    });
  });
}
