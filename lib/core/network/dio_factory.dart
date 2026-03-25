import 'package:dio/dio.dart';
import 'package:mvvm/config/environment.dart';
import 'package:mvvm/core/network/auth_interceptor.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';

class DioFactory {
  static Dio createDio(AuthStored storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrlRemoteApi,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {"Content-Type": "application/json", "Accept": "*/*"},
      ),
    );

    ///Fez necessário criar um novo dio, porque se não acontecia um loop
    ///infinito nos interceptors. E ele será usado apenas para fazer uma
    ///nova requisição para obter o novo token
    final refreshDio = Dio(BaseOptions(baseUrl: Environment.baseUrlRemoteApi));

    ///Eu tomei a decisão de criar AuthInterceptor, para separar bem as
    ///responsabilidades, e seguir o padrão SRP – Single Responsibility Principle
    ///
    ///Quando eu fiz tudo junto, vi que o dio principal ficava muito poluído e
    ///responsavel por muita coisa, configuração, regra de negócio etc
    ///
    ///Dessa forma, o dio fica somente responsável pelas configurações
    ///e o AuthInterceptor fica responsavel pela autenticação
    ///(obter novo token, fazer o refresh e outras responsabilidades)
    dio.interceptors.add(AuthInterceptor(storage, refreshDio, dio));

    return dio;
  }
}
