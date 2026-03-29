import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/ui/auth/view_model/auth_login_viewmodel.dart';
import 'package:mvvm/ui/widgets/common/show_dialog_error_widget.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';
import 'package:provider/provider.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cmd = context.read<AuthLoginViewModel>().loginCommand;

    return ListenableBuilder(
      listenable: cmd,
      builder: (context, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      const _Title(),
                      const SizedBox(height: 32),

                      _EmailField(controller: emailController),

                      _PasswordField(
                        controller: senhaController,
                        onSubmit: () => _submit(cmd),
                      ),
                      const SizedBox(height: 24),

                      _LoginButton(
                        isLoading: cmd.running,
                        onPressed: () => _submit(cmd),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(Command1 cmd) async {
    if (!_formKey.currentState!.validate()) return;

    final request = AuthLoginRequest(
      email: emailController.text,
      senha: senhaController.text,
    );

    await cmd.execute(request);

    if (mounted && cmd.error) {
      final messageError = (cmd.result as Failure).error;

      showDialog(
        context: context,
        builder: (context) {
          return ShowDialogErrorWidget(message: messageError.toString());
        },
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Bem-vindo',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || !value.contains('@')) {
          return 'E-mail inválido';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _PasswordField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: const InputDecoration(
        labelText: 'Senha',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value != null && value.length < 6) {
          return 'Senha muito curta';
        }
        return null;
      },
      onFieldSubmitted: (_) => onSubmit(),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('ENTRAR'),
      ),
    );
  }
}
