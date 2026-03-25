import 'package:flutter/material.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/routing/app_router.dart';
import 'package:mvvm/ui/auth/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await getDependecies();

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final authRepository = context.read<AuthRepository>();

    final router = createRouter(
      authViewModel: authViewModel,
      authRepository: authRepository,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Usuários',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
