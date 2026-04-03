import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mvvm/core/exceptions/http_exception.dart';
import 'package:mvvm/data/services/user/user_service.dart';
import 'package:mvvm/domain/models/user/user.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late UserService userService;

  final userJson = {
    'id': 1,
    'nome': 'João',
    'email': 'joao@email.com',
    'senha': '123456',
  };

  final userJson2 = {
    'id': 2,
    'nome': 'Maria',
    'email': 'maria@email.com',
    'senha': '654321',
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/'));
    dioAdapter = DioAdapter(dio: dio);
    userService = UserService(dio);
  });

  group('UserService - getAll', () {
    test('deve retornar lista de usuários no sucesso', () async {
      dioAdapter.onGet(
        'user',
        (server) => server.reply(200, [userJson, userJson2]),
      );

      final users = await userService.getAll();

      expect(users.length, 2);
      expect(users[0].nome, 'João');
      expect(users[1].nome, 'Maria');
    });

    test('deve retornar lista vazia', () async {
      dioAdapter.onGet('user', (server) => server.reply(200, []));

      final users = await userService.getAll();

      expect(users, isEmpty);
    });

    test('deve lançar exceção em erro', () async {
      dioAdapter.onGet(
        'user',
        (server) => server.reply(500, {'message': 'Erro'}),
      );

      expect(() => userService.getAll(), throwsA(isA<ServerException>()));
    });
  });

  group('UserService - getById', () {
    test('deve retornar usuário no sucesso', () async {
      dioAdapter.onGet('user/1', (server) => server.reply(200, userJson));

      final user = await userService.getById(1);

      expect(user.id, 1);
      expect(user.nome, 'João');
    });

    test('deve lançar NotFoundException em 404', () async {
      dioAdapter.onGet(
        'user/999',
        (server) => server.reply(404, {'message': 'Não encontrado'}),
      );

      expect(
        () => userService.getById(999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('UserService - create', () {
    test('deve retornar usuário criado no sucesso', () async {
      final newUser = User(nome: 'Novo', email: 'novo@email.com', senha: '123456');

      dioAdapter.onPost(
        'user',
        (server) => server.reply(201, {
          'id': 3,
          'nome': 'Novo',
          'email': 'novo@email.com',
          'senha': '123456',
        }),
        data: newUser.toJson(),
      );

      final created = await userService.create(newUser);

      expect(created.id, 3);
      expect(created.nome, 'Novo');
    });

    test('deve lançar exceção em erro de validação', () async {
      final newUser = User(nome: '', email: 'invalid', senha: '123');

      dioAdapter.onPost(
        'user',
        (server) => server.reply(422, {'message': 'Validação falhou'}),
        data: newUser.toJson(),
      );

      expect(
        () => userService.create(newUser),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('UserService - update', () {
    test('deve retornar usuário atualizado no sucesso', () async {
      final user = User(id: 1, nome: 'Atualizado', email: 'att@email.com', senha: '123456');

      dioAdapter.onPut(
        'user/1',
        (server) => server.reply(200, user.toJson()),
        data: user.toJson(),
      );

      final updated = await userService.update(1, user);

      expect(updated.nome, 'Atualizado');
    });

    test('deve lançar exceção em erro', () async {
      final user = User(id: 1, nome: 'Test', email: 'test@email.com', senha: '123456');

      dioAdapter.onPut(
        'user/1',
        (server) => server.reply(400, {'message': 'Erro'}),
        data: user.toJson(),
      );

      expect(
        () => userService.update(1, user),
        throwsA(isA<BadRequestException>()),
      );
    });
  });

  group('UserService - delete (detele)', () {
    test('deve completar sem erro no sucesso', () async {
      dioAdapter.onDelete('user/1', (server) => server.reply(204, null));

      await expectLater(userService.detele(1), completes);
    });

    test('deve lançar exceção em erro', () async {
      dioAdapter.onDelete(
        'user/999',
        (server) => server.reply(404, {'message': 'Não encontrado'}),
      );

      expect(
        () => userService.detele(999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
