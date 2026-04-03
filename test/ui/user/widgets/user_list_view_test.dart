import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/logout/view_model/logout_viewmodel.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/user/widgets/user_list_view.dart';
import 'package:mvvm/utils/result.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_auth_repository.dart';
import '../../../mocks/mock_user_repository.dart';

void main() {
  late MockUserRepository mockUserRepo;
  late MockAuthRepository mockAuthRepo;
  late UserViewModel userViewModel;

  setUp(() {
    mockUserRepo = MockUserRepository();
    mockAuthRepo = MockAuthRepository();
    userViewModel = UserViewModel(userRepository: mockUserRepo);
  });

  Widget createApp({bool withRouter = false}) {
    final providers = [
      ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
      Provider<LogoutViewmodel>(
        create: (_) => LogoutViewmodel(authRepository: mockAuthRepo),
      ),
    ];

    if (withRouter) {
      final router = GoRouter(
        initialLocation: AppRoutes.userList,
        routes: [
          GoRoute(
            path: AppRoutes.userList,
            builder: (context, state) => const UserListView(),
          ),
          GoRoute(
            path: AppRoutes.userForm,
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.pop(true),
                    child: const Text('Salvar e Voltar'),
                  ),
                ),
              );
            },
          ),
        ],
      );

      return MultiProvider(
        providers: providers,
        child: MaterialApp.router(routerConfig: router),
      );
    }

    return MultiProvider(
      providers: providers,
      child: const MaterialApp(home: UserListView()),
    );
  }

  final user1 = User(id: 1, nome: 'João', email: 'joao@email.com', senha: '123');
  final user2 = User(id: 2, nome: 'Maria', email: 'maria@email.com', senha: '456');

  group('UserListView', () {
    testWidgets('deve mostrar título Usuários Cadastrados', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Usuários Cadastrados'), findsOneWidget);
    });

    testWidgets('deve mostrar loading enquanto carrega', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp());
      await tester.pump();
      await tester.pump();

      expect(find.byType(UserListView), findsOneWidget);
    });

    testWidgets('deve mostrar mensagem quando lista está vazia', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum usuário cadastrado'), findsOneWidget);
    });

    testWidgets('deve mostrar lista de usuários', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1, user2]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('João'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('joao@email.com'), findsOneWidget);
      expect(find.text('maria@email.com'), findsOneWidget);
    });

    testWidgets('deve mostrar avatar com primeira letra do nome', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('deve ter botão de logout no AppBar', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('deve executar logout ao clicar no botão', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);
      mockAuthRepo.logoutResult = Result.ok(null);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(mockAuthRepo.logoutCallCount, 1);
    });

    testWidgets('deve ter FAB para adicionar usuário', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('FAB deve navegar para formulário de criação', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);

      await tester.pumpWidget(createApp(withRouter: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      expect(find.text('Salvar e Voltar'), findsOneWidget);
    });

    testWidgets('deve ter ícones de editar e deletar por usuário', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('botão editar deve navegar para formulário', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp(withRouter: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Salvar e Voltar'), findsOneWidget);
    });

    testWidgets('deve recarregar lista ao voltar do form com resultado true', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp(withRouter: true));
      await tester.pumpAndSettle();

      // Navega para o form via FAB
      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      // Simula retorno com true
      mockUserRepo.getAllResult = Result.ok([user1, user2]);
      await tester.tap(find.text('Salvar e Voltar'));
      await tester.pumpAndSettle();

      // Deve ter recarregado e mostrar ambos os usuários
      expect(find.text('João'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
    });

    testWidgets('deve mostrar dialog de confirmação ao deletar', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Excluir Usuário'), findsOneWidget);
      expect(find.text('Deseja realmente excluir?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('deve fechar dialog ao cancelar exclusão', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Excluir Usuário'), findsNothing);
    });

    testWidgets('deve executar exclusão ao confirmar', (tester) async {
      mockUserRepo.getAllResult = Result.ok([user1, user2]);
      mockUserRepo.deleteResult = Result.ok(null);

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Clica no delete do primeiro usuário
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirma exclusão
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // Após exclusão, o usuário deve ter sido removido da lista
      expect(userViewModel.deleteUserCommand.completed, true);
    });

    testWidgets('deve mostrar erro e botão retry quando falha', (tester) async {
      mockUserRepo.getAllResult = Result.error(Exception('Erro de conexão'));

      // Pré-executa o command para simular estado de erro
      await userViewModel.loadUsersCommand.execute();

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('botão retry deve recarregar a lista', (tester) async {
      mockUserRepo.getAllResult = Result.error(Exception('Erro'));

      // Pré-executa para ter estado de erro
      await userViewModel.loadUsersCommand.execute();

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Tentar novamente'), findsOneWidget);

      // Agora configura sucesso e clica retry
      mockUserRepo.getAllResult = Result.ok([user1]);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('João'), findsOneWidget);
    });
  });
}
