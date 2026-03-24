import 'package:dio/dio.dart';
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = storage.refreshToken;

            if (refreshToken == null) {
              await storage.clear();
              return handler.next(error);
            }

            try {
              final refreshDio = Dio();
              final response = await refreshDio.post(
                "http://192.168.15.89:5229/api/auth/refresh",
                data: {"refreshtoken": refreshToken},
              );

              final newAcessToken = response.data["accessToken"];
              final newRefreshToken = response.data["refreshToken"];

              await storage.saveTokens(newAcessToken, newRefreshToken);

              final requestOptions = error.requestOptions;
              requestOptions.headers["Authorization"] = "Bearer $newAcessToken";

              final cloneResponse = await dio.fetch(requestOptions);
              return handler.resolve(cloneResponse);
            } catch (e) {
              await storage.clear();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
    return dio;
  }
}
