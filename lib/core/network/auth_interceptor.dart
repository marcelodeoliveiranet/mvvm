import 'package:dio/dio.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';

class AuthInterceptor extends Interceptor {
  final AuthStored _storage;
  final Dio _refreshDio; // Usado apenas para pedir o novo token
  final Dio _mainDio; // Usado para repetir a requisição original

  AuthInterceptor(this._storage, this._refreshDio, this._mainDio);

  /// 1. Injeta o token em todas as requisições que saem
  /// O que acontece aqui: Quando se faz, por exemplo, um dio.get(/users),
  /// o interceptador interpreta a requisição ANTES de ir para a API e gera este
  /// evento
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    ///Apos os passos acima, o comando abaixo diz ao Dio
    ///para continuar com o fluxo normalmente
    return handler.next(options);
  }

  /// 2. Intercepta erros 401 para tentar o refresh
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    /// Se não for erro 401 (Não autorizado), segue o fluxo normal do erro
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    /// Se o erro aconteceu na própria rota de refresh, desloga o usuário
    /// para um novo login
    if (err.requestOptions.path.contains('auth/refresh')) {
      await _storage.clear();

      /// Redirecionar para um novo login e segue o fluxo
      /// normal
      return handler.next(err);
    }

    try {
      final refreshToken = _storage.refreshToken;

      ///Se não existir o token de refresh, não tem como renovar
      ///redireciona para um novo login
      if (refreshToken == null) {
        await _storage.clear();
        return handler.next(err);
      }

      /// Faz a chamada de refresh usando a instância separada (_refreshDio)
      /// É necessário ter a instancia separada de um outro Dio para evitar loop
      /// infinito e efeitos colaterais dos interceptors.
      final response = await _refreshDio.post(
        'auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      ///Status code = 200 sigfinica que o post acima deu certo
      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        // Salva os novos tokens no storage
        await _storage.saveTokens(newAccessToken, newRefreshToken);

        // Atualiza o cabeçalho da requisição que falhou e repete ela usando o _mainDio
        ///A variavel requestOptions irá armazenar, por exemplo, a URL original, o método
        ///que pode ser um post ou get, o body e query params
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        ///O código abaixo pode ser interpretado como algo assim:
        ///Refaça exatamente a mesma requisição, porém com tokem novo
        final clonedRequest = await _mainDio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        // Retorna a resposta da requisição repetida com sucesso
        return handler.resolve(clonedRequest);
      }
    } catch (e) {
      /// Se deu erro ao tentar dar refresh, por exemplo, o refresh
      /// expirou, a API pode estar fora do ar, limpa tudo e desloga
      /// para um novo login
      await _storage.clear();
    }

    ///Como eu já estou dentro do evento de erro que aconteceu no dio,
    ///que pode ser qualquer erro, ele diz para passar este erro
    ///para o próximo interceptor, ou devolver para quem fez a
    ///requisição
    ///
    ///O return abaixo, dentro do evento onError diz que não irá
    ///tratar o erro e pode continuar o fluxo normal
    return handler.next(err);
  }
}
