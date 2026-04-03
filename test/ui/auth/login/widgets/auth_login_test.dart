import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:mvvm/ui/auth/login/widgets/auth_login.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/utils/result.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_auth_repository.dart';
import '../../../../mocks/mock_user_repository.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
  });

  Widget createApp() {
    final mockUserRepo = MockUserRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const AuthLogin(),
        ),
        GoRoute(
          path: AppRoutes.userForm,
          builder: (context, state) => const Scaffold(body: Text('User Form')),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        Provider<LoginViewmodel>(
          create: (_) => LoginViewmodel(authRepository: mockAuthRepo),
        ),
        ChangeNotifierProvider<UserViewModel>(
          create: (_) => UserViewModel(userRepository: mockUserRepo),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('AuthLogin Widget', () {
    testWidgets('deve renderizar campos de email e senha', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('deve renderizar título Bem-vindo', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo'), findsOneWidget);
    });

    testWidgets('deve renderizar botões Cadastrar e Entrar', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('deve mostrar erro de email inválido', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Preenche email sem @ e senha válida
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      // Toca em Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro de senha curta', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, '123');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Senha muito curta'), findsOneWidget);
    });

    testWidgets('deve chamar loginCommand com dados válidos', (tester) async {
      mockAuthRepo.loginResult = Result.ok(
        AuthResponse(accessToken: 'a', refreshToken: 'r'),
      );

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(mockAuthRepo.loginCallCount, 1);
    });

    testWidgets('deve mostrar dialog de erro no login falho', (tester) async {
      mockAuthRepo.loginResult = Result.error(Exception('Credenciais inválidas'));

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Erro'), findsOneWidget);
    });

    testWidgets('botão Cadastrar deve navegar para user-form', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('User Form'), findsOneWidget);
    });
  });
}
