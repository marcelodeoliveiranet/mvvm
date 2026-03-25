// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShowDialogErrorWidget extends StatelessWidget {
  final String message;

  const ShowDialogErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Erro"),
      content: Text(message, style: TextStyle(fontSize: 20)),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Ok", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
