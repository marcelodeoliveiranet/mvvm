import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/widgets/common/show_dialog_error_widget.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

class UserFormPage extends StatefulWidget {
  final UserViewModel userViewModel;
  final User? user;

  const UserFormPage({super.key, required this.userViewModel, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Command get _command => widget.user == null
      ? widget.userViewModel.createUserCommand
      : widget.userViewModel.updateUserCommand;

  Future<void> _gravar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      id: widget.user?.id ?? 0,
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (widget.user == null) {
      await widget.userViewModel.createUserCommand.execute(user);
    } else {
      await widget.userViewModel.updateUserCommand.execute(user);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _nomeController.text = widget.user!.nome;
      _emailController.text = widget.user!.email;
      _senhaController.text = widget.user!.senha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cmd = _command;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Cadastrar Usuário' : 'Editar Usuário',
        ),
      ),

      body: ListenableBuilder(
        listenable: cmd,
        builder: (context, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final result = cmd.result;

            if (result == null) return;

            switch (result) {
              case Ok():
                if (mounted) {
                  Navigator.pop(context, true);
                }
                cmd.clearResult();

              case Failure(error: final e):
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        ShowDialogErrorWidget(message: e.toString()),
                  );
                }
                cmd.clearResult();
            }
          });

          final isLoading = cmd.running;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nomeController,
                            autofocus: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Informe o nome'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe o email';
                              }
                              if (!value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _senhaController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe a senha';
                              }
                              if (value.length < 6) {
                                return 'Mínimo de 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _gravar,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.user == null ? 'Cadastrar' : 'Atualizar',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
