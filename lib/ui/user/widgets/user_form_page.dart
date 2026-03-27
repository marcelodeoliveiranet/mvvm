import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/widgets/common/show_dialog_error_widget.dart';
import 'package:mvvm/utils/view_model_state.dart';

class UserFormPage extends StatefulWidget {
  final UserViewModel userViewModel;
  final User? user;
  const UserFormPage({super.key, required this.userViewModel, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _gravar() async {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text;
      final email = _emailController.text;
      final senha = _senhaController.text;

      final user = User(
        id: widget.user?.id == null ? 0 : widget.user!.id,
        nome: nome,
        email: email,
        senha: senha,
      );

      if (widget.user == null) {
        await widget.userViewModel.createUser(user);
      } else {
        await widget.userViewModel.updateUser(user);
      }
    }
  }

  void _listener() {
    final viewModel = widget.userViewModel;

    if (viewModel.state == ViewModelState.loading) {
      CircularProgressIndicator();
    }

    if (viewModel.state == ViewModelState.success && mounted) {
      Navigator.pop(context, true);
    }

    if (viewModel.state == ViewModelState.error && mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return ShowDialogErrorWidget(message: viewModel.errorMessage!);
        },
      );
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

    widget.userViewModel.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.userViewModel;
    final isLoading = viewModel.state == ViewModelState.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Cadastrar Usuário' : 'Editar Usuário',
        ),
      ),
      body: Padding(
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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

            // 🔻 BOTÃO
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
