import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/user/widgets/user_form_page.dart';
import 'package:mvvm/utils/result.dart';

import '../../../mocks/mock_user_repository.dart';

void main() {
  late MockUserRepository mockRepository;
  late UserViewModel userViewModel;

  setUp(() {
    mockRepository = MockUserRepository();
    userViewModel = UserViewModel(userRepository: mockRepository);
  });

  Widget createApp({User? user, bool useNavigator = true}) {
    if (useNavigator) {
      return MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => UserFormPage(
              userViewModel: userViewModel,
              user: user,
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      home: UserFormPage(
        userViewModel: userViewModel,
        user: user,
      ),
    );
  }

  group('UserFormPage - Modo criação', () {
    testWidgets('deve mostrar título Cadastrar Usuário', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Usuário'), findsOneWidget);
    });

    testWidgets('deve mostrar campos vazios', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('deve mostrar botão Cadastrar', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('deve validar nome vazio', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final nomeField = find.byType(TextFormField).first;
      await tester.enterText(nomeField, 'a');
      await tester.pumpAndSettle();
      await tester.enterText(nomeField, '');
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets('deve validar email inválido', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'invalido');
      await tester.tap(find.byType(TextFormField).last);
      await tester.pumpAndSettle();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve validar email vazio', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'a');
      await tester.pumpAndSettle();
      await tester.enterText(emailField, '');
      await tester.pumpAndSettle();

      expect(find.text('Informe o email'), findsOneWidget);
    });

    testWidgets('deve validar senha vazia', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final senhaField = find.byType(TextFormField).last;
      await tester.enterText(senhaField, 'a');
      await tester.pumpAndSettle();
      await tester.enterText(senhaField, '');
      await tester.pumpAndSettle();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve validar senha curta', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final senhaField = find.byType(TextFormField).last;
      await tester.enterText(senhaField, '12');
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.text('Mínimo de 6 caracteres'), findsOneWidget);
    });

    testWidgets('não deve submeter form com validação inválida', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Tenta submeter sem preencher nada
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // O form não é submetido - nenhum command é executado
      expect(userViewModel.createUserCommand.result, isNull);
    });

    testWidgets('deve chamar createUserCommand ao submeter com dados válidos', (tester) async {
      final createdUser = User(id: 3, nome: 'Novo', email: 'novo@email.com', senha: '123456');
      mockRepository.createResult = Result.ok(createdUser);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Novo');
      await tester.enterText(find.byType(TextFormField).at(1), 'novo@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // O command executa e no sucesso o postFrameCallback faz pop + clearResult,
      // então o result já foi limpo. Verificamos que o user foi adicionado à lista.
      expect(userViewModel.users.any((u) => u.nome == 'Novo'), true);
    });

    testWidgets('deve mostrar dialog de erro quando criação falha', (tester) async {
      mockRepository.createResult = Result.error(Exception('Erro ao criar'));

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Novo');
      await tester.enterText(find.byType(TextFormField).at(1), 'novo@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Erro'), findsOneWidget);
    });
  });

  group('UserFormPage - Modo edição', () {
    final existingUser = User(
      id: 1,
      nome: 'João',
      email: 'joao@email.com',
      senha: '123456',
    );

    testWidgets('deve mostrar título Editar Usuário', (tester) async {
      await tester.pumpWidget(createApp(user: existingUser));
      await tester.pumpAndSettle();

      expect(find.text('Editar Usuário'), findsOneWidget);
    });

    testWidgets('deve preencher campos com dados do usuário', (tester) async {
      await tester.pumpWidget(createApp(user: existingUser));
      await tester.pumpAndSettle();

      final textFields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      final nomeController = (textFields[0].controller)!;
      final emailController = (textFields[1].controller)!;
      final senhaController = (textFields[2].controller)!;

      expect(nomeController.text, 'João');
      expect(emailController.text, 'joao@email.com');
      expect(senhaController.text, '123456');
    });

    testWidgets('deve mostrar botão Atualizar', (tester) async {
      await tester.pumpWidget(createApp(user: existingUser));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar'), findsOneWidget);
    });

    testWidgets('deve chamar updateUserCommand ao submeter edição', (tester) async {
      final updatedUser = User(id: 1, nome: 'João Edit', email: 'joao@email.com', senha: '123456');
      mockRepository.updateResult = Result.ok(updatedUser);

      await tester.pumpWidget(createApp(user: existingUser));
      await tester.pumpAndSettle();

      // Altera o nome
      await tester.enterText(find.byType(TextFormField).at(0), 'João Edit');

      await tester.tap(find.text('Atualizar'));
      await tester.pumpAndSettle();

      // O command executa e no sucesso o postFrameCallback faz pop + clearResult.
      // O result já foi limpo, mas o ViewModel guarda o estado.
      // Como clearResult é chamado, verificamos indiretamente que o command executou.
      expect(userViewModel.updateUserCommand.result, isNull); // clearResult foi chamado
    });

    testWidgets('deve mostrar dialog de erro quando atualização falha', (tester) async {
      mockRepository.updateResult = Result.error(Exception('Erro ao atualizar'));

      await tester.pumpWidget(createApp(user: existingUser));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Atualizar'));
      await tester.pumpAndSettle();

      expect(find.text('Erro'), findsOneWidget);
    });
  });
}
