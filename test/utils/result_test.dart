import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/utils/result.dart';

void main() {
  group('Result', () {
    group('Ok', () {
      test('deve criar instância Ok com valor', () {
        final result = Result.ok(42);

        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).value, 42);
      });

      test('deve funcionar com tipos complexos', () {
        final result = Result.ok(['a', 'b', 'c']);

        expect(result, isA<Ok<List<String>>>());
        expect((result as Ok<List<String>>).value, ['a', 'b', 'c']);
      });

      test('deve funcionar com valor nulo', () {
        final result = Result.ok(null);

        expect(result, isA<Ok<void>>());
      });

      test('toString deve retornar formato correto', () {
        final result = Result.ok(42);

        expect(result.toString(), 'Result<int>.ok(42)');
      });
    });

    group('Failure', () {
      test('deve criar instância Failure com exceção', () {
        final exception = Exception('falhou');
        final result = Result<int>.error(exception);

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error, exception);
      });

      test('toString deve retornar formato correto', () {
        final result = Result<int>.error(Exception('erro'));

        expect(result.toString(), contains('Result<int>.error'));
      });
    });

    group('Pattern matching', () {
      test('deve fazer pattern matching com Ok', () {
        final result = Result.ok('sucesso');

        final valor = switch (result) {
          Ok(value: final v) => v,
          Failure() => 'falhou',
        };

        expect(valor, 'sucesso');
      });

      test('deve fazer pattern matching com Failure', () {
        final result = Result<String>.error(Exception('erro'));

        final valor = switch (result) {
          Ok(value: final v) => v,
          Failure(error: final e) => e.toString(),
        };

        expect(valor, contains('erro'));
      });
    });
  });
}
