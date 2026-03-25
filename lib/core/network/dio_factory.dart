import 'package:dio/dio.dart';
import 'package:mvvm/core/network/auth_interceptor.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';

class DioFactory {
  static Dio createDio(AuthStored storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.15.22:51137/api/",
        connectTimeout: const Duration(seconds: 18),
        receiveTimeout: const Duration(seconds: 18),
        headers: {"Content-Type": "application/json", "Accept": "*/*"},
      ),
    );

    final refreshDio = Dio(
      BaseOptions(baseUrl: "http://192.168.15.22:51137/api/"),
    );

    dio.interceptors.add(AuthInterceptor(storage, refreshDio, dio));

    return dio;
  }
}
