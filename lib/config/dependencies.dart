import 'package:dio/dio.dart';
import 'package:mvvm/core/network/dio_factory.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/data/repositories/user/user_repository_impl_remote.dart';
import 'package:mvvm/data/services/user/user_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<SingleChildWidget>> getDependecies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return [
    Provider<SharedPreferences>.value(value: sharedPreferences),

    Provider<AuthStored>(
      create: (context) => AuthStored(context.read<SharedPreferences>()),
    ),

    Provider<Dio>(
      create: (context) => DioFactory.createDio(context.read<AuthStored>()),
    ),

    Provider<UserService>(
      create: (context) => UserService(context.read<Dio>()),
    ),

    Provider<UserRepository>(
      create: (context) =>
          UserRepositoryImplRemote(context.read<UserService>()),
    ),
  ];
}
