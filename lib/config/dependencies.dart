import 'package:dio/dio.dart';
import 'package:mvvm/core/network/dio_factory.dart';
import 'package:mvvm/data/services/local/shared_preferences_service.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/data/repositories/auth/auth_repository_impl_remote.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/data/repositories/user/user_repository_impl_remote.dart';
import 'package:mvvm/data/services/auth/auth_service.dart';
import 'package:mvvm/data/services/user/user_service.dart';
import 'package:mvvm/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:mvvm/ui/auth/logout/view_model/logout_viewmodel.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<SingleChildWidget>> getDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return [
    Provider<SharedPreferences>.value(value: sharedPreferences),

    Provider<SharedPreferencesService>(
      create: (context) =>
          SharedPreferencesService(context.read<SharedPreferences>()),
    ),

    Provider<Dio>(
      create: (context) =>
          DioFactory.createDio(context.read<SharedPreferencesService>()),
    ),

    ///Services
    Provider<UserService>(
      create: (context) => UserService(context.read<Dio>()),
    ),

    Provider<AuthService>(
      create: (context) => AuthService(context.read<Dio>()),
    ),

    ///Repositories
    Provider<UserRepository>(
      create: (context) =>
          UserRepositoryImplRemote(context.read<UserService>()),
    ),

    ChangeNotifierProvider<AuthRepository>(
      create: (context) => AuthRepositoryImplRemote(
        authService: context.read(),
        authLocalService: context.read(),
      ),
    ),

    ///ViewModel
    Provider<LoginViewmodel>(
      create: (context) => LoginViewmodel(authRepository: context.read()),
    ),

    Provider<LogoutViewmodel>(
      create: (context) => LogoutViewmodel(authRepository: context.read()),
    ),

    ChangeNotifierProvider<UserViewModel>(
      create: (context) =>
          UserViewModel(userRepository: context.read<UserRepository>()),
    ),
  ];
}
