import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/ui/widgets/common/show_dialog_error_widget.dart';

void main() {
  group('ShowDialogErrorWidget', () {
    testWidgets('deve mostrar título Erro', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ShowDialogErrorWidget(
                              message: 'Algo deu errado',
                            ),
                          );
                        },
                        child: const Text('Abrir'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Erro'), findsOneWidget);
      expect(find.text('Algo deu errado'), findsOneWidget);
      expect(find.text('Ok'), findsOneWidget);
    });

    testWidgets('deve fechar ao clicar Ok', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ShowDialogErrorWidget(
                              message: 'Erro teste',
                            ),
                          );
                        },
                        child: const Text('Abrir'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      expect(find.text('Erro teste'), findsNothing);
    });
  });
}
