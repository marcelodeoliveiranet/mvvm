import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

void main() {
  group('Command0', () {
    test('estado inicial deve ser idle', () {
      final cmd = Command0<String>(() async => Result.ok('ok'));

      expect(cmd.running, false);
      expect(cmd.error, false);
      expect(cmd.completed, false);
      expect(cmd.result, isNull);
    });

    test('deve ficar running=true durante execução', () async {
      final completer = Completer<Result<String>>();
      final cmd = Command0<String>(() => completer.future);

      final future = cmd.execute();

      expect(cmd.running, true);
      expect(cmd.completed, false);

      completer.complete(Result.ok('done'));
      await future;

      expect(cmd.running, false);
      expect(cmd.completed, true);
    });

    test('deve ficar completed=true após sucesso', () async {
      final cmd = Command0<String>(() async => Result.ok('sucesso'));

      await cmd.execute();

      expect(cmd.running, false);
      expect(cmd.completed, true);
      expect(cmd.error, false);
      expect((cmd.result! as Ok<String>).value, 'sucesso');
    });

    test('deve ficar error=true após falha', () async {
      final cmd = Command0<String>(
        () async => Result.error(Exception('falhou')),
      );

      await cmd.execute();

      expect(cmd.running, false);
      expect(cmd.completed, false);
      expect(cmd.error, true);
      expect(cmd.result, isA<Failure>());
    });

    test('deve prevenir execução duplicada', () async {
      var callCount = 0;
      final completer = Completer<Result<String>>();

      final cmd = Command0<String>(() {
        callCount++;
        return completer.future;
      });

      final future1 = cmd.execute();
      final future2 = cmd.execute(); // deve ser ignorada

      completer.complete(Result.ok('ok'));
      await future1;
      await future2;

      expect(callCount, 1);
    });

    test('clearResult deve limpar resultado e notificar', () async {
      final cmd = Command0<String>(() async => Result.ok('ok'));

      await cmd.execute();
      expect(cmd.result, isNotNull);

      var notified = false;
      cmd.addListener(() => notified = true);
      cmd.clearResult();

      expect(cmd.result, isNull);
      expect(cmd.completed, false);
      expect(cmd.error, false);
      expect(notified, true);
    });

    test('deve notificar listeners durante execução', () async {
      final cmd = Command0<String>(() async => Result.ok('ok'));
      final notifications = <bool>[];

      cmd.addListener(() => notifications.add(cmd.running));

      await cmd.execute();

      // Primeira notificação: running=true, Segunda: running=false
      expect(notifications, [true, false]);
    });
  });

  group('Command1', () {
    test('deve executar com argumento', () async {
      final cmd = Command1<int, int>((n) async => Result.ok(n * 2));

      await cmd.execute(5);

      expect(cmd.completed, true);
      expect((cmd.result! as Ok<int>).value, 10);
    });

    test('deve passar argumento corretamente', () async {
      String? receivedArg;
      final cmd = Command1<String, String>((arg) async {
        receivedArg = arg;
        return Result.ok(arg);
      });

      await cmd.execute('hello');

      expect(receivedArg, 'hello');
    });

    test('deve prevenir execução duplicada com argumento', () async {
      var callCount = 0;
      final completer = Completer<Result<String>>();

      final cmd = Command1<String, String>((arg) {
        callCount++;
        return completer.future;
      });

      final future1 = cmd.execute('a');
      final future2 = cmd.execute('b'); // deve ser ignorada

      completer.complete(Result.ok('ok'));
      await future1;
      await future2;

      expect(callCount, 1);
    });

    test('deve ficar error=true após falha', () async {
      final cmd = Command1<String, int>(
        (n) async => Result.error(Exception('erro')),
      );

      await cmd.execute(1);

      expect(cmd.error, true);
      expect(cmd.completed, false);
    });
  });
}
