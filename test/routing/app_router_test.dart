import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/routing/app_router.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/auth/logout/view_model/logout_viewmodel.dart';
import 'package:mvvm/utils/result.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_auth_repository.dart';
import '../mocks/mock_user_repository.dart';

void main() {
  group('AppRoutes', () {
    test('login deve ser /login', () {
      expect(AppRoutes.login, '/login');
    });

    test('userList deve ser /users', () {
      expect(AppRoutes.userList, '/users');
    });

    test('userForm deve ser /user-form', () {
      expect(AppRoutes.userForm, '/user-form');
    });
  });

  group('Router redirect', () {
    late MockAuthRepository mockAuthRepo;
    late MockUserRepository mockUserRepo;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockUserRepo = MockUserRepository();
    });

    Widget buildApp(router) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserViewModel>(
            create: (_) => UserViewModel(userRepository: mockUserRepo),
          ),
          Provider<LogoutViewmodel>(
            create: (_) => LogoutViewmodel(authRepository: mockAuthRepo),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('deve mostrar login quando não autenticado', (tester) async {
      final router = createRouter(authRepository: mockAuthRepo);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo'), findsOneWidget);
    });

    testWidgets('deve redirecionar para /users quando autenticado e indo para /login', (tester) async {
      mockAuthRepo.isLoggedIn = true;
      mockUserRepo.getAllResult = Result.ok([]);
      final router = createRouter(authRepository: mockAuthRepo);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      expect(find.text('Usuários Cadastrados'), findsOneWidget);
    });

    testWidgets('deve redirecionar para /login quando não autenticado e indo para /users', (tester) async {
      // Não autenticado tentando acessar /users
      final router = createRouter(authRepository: mockAuthRepo);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      // Tenta navegar para /users programaticamente
      router.go(AppRoutes.userList);
      await tester.pumpAndSettle();

      // Deve ter redirecionado para login
      expect(find.text('Bem-vindo'), findsOneWidget);
    });

    testWidgets('deve permitir acesso a /user-form sem autenticação', (tester) async {
      // O router tem uma regra especial para /user-form sem autenticação
      final router = createRouter(authRepository: mockAuthRepo);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      // Navega para /user-form
      router.go(AppRoutes.userForm);
      await tester.pumpAndSettle();

      // Deve mostrar o formulário (título Cadastrar Usuário)
      expect(find.text('Cadastrar Usuário'), findsOneWidget);
    });

    testWidgets('deve reagir a mudanças de autenticação via refreshListenable', (tester) async {
      mockUserRepo.getAllResult = Result.ok([]);
      final router = createRouter(authRepository: mockAuthRepo);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      // Inicialmente na tela de login
      expect(find.text('Bem-vindo'), findsOneWidget);

      // Simula login
      mockAuthRepo.isLoggedIn = true;
      await tester.pumpAndSettle();

      // Deve redirecionar para lista de usuários
      expect(find.text('Usuários Cadastrados'), findsOneWidget);
    });
  });
}
