import 'package:dio/dio.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';

class AuthInterceptor extends Interceptor {
  final AuthStored _storage;
  final Dio _refreshDio; // Usado apenas para pedir o novo token
  final Dio _mainDio; // Usado para repetir a requisição original falha

  AuthInterceptor(this._storage, this._refreshDio, this._mainDio);

  // 1. Injeta o token em todas as requisições que saem
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  // 2. Intercepta erros 401 para tentar o refresh
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se não for erro 401 (Não autorizado), segue o fluxo normal do erro
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Se o erro aconteceu na própria rota de refresh, desloga o usuário
    if (err.requestOptions.path.contains('auth/refresh')) {
      await _storage.clear();
      // Redirecionar para login (via ViewModel ou EventBus)
      return handler.next(err);
    }

    try {
      final refreshToken = _storage.refreshToken;

      if (refreshToken == null) {
        await _storage.clear();
        return handler.next(err);
      }

      // Faz a chamada de refresh usando a instância separada (_refreshDio)
      final response = await _refreshDio.post(
        'auth/refresh', // Ajuste para o seu endpoint real
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        // Salva os novos tokens no storage
        await _storage.saveTokens(newAccessToken, newRefreshToken);

        // Atualiza o cabeçalho da requisição que falhou e repete ela usando o _mainDio
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final clonedRequest = await _mainDio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        // Retorna a resposta da requisição repetida com sucesso!
        return handler.resolve(clonedRequest);
      }
    } catch (e) {
      // Se deu erro ao tentar dar refresh (ex: refresh expirou), limpa tudo e desloga
      await _storage.clear();
    }

    return handler.next(err);
  }
}
