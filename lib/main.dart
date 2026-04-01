import 'package:flutter/material.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/routing/app_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await getDependencies();

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authRepository: context.read<AuthRepository>());

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
