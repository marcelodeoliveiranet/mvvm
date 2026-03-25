import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/ui/auth/view_model/auth_login_viewmodel.dart';
import 'package:mvvm/ui/auth/view_model/auth_view_model.dart';
import 'package:mvvm/utils/view_model_state.dart';
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
    return Consumer<AuthLoginViewModel>(
      builder: (context, vm, child) {
        if (vm.state == ViewModelState.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (vm.state == ViewModelState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  child: const Text("Tentar novamente"),
                ),
              ],
            ),
          );
        }

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
                    children: [
                      Text(
                        'Bem-vindo',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Campo de Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        //onChanged: (value) => _viewModel.email = value,
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                            ? 'E-mail inválido'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo de Senha
                      TextFormField(
                        controller: senhaController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            (value != null && value.length < 6)
                            ? 'Senha muito curta'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Botão de Login
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final authVM = context.read<AuthViewModel>();

                            final authLoginRequest = AuthLoginRequest(
                              email: emailController.text,
                              senha: senhaController.text,
                            );

                            final success = await vm.login(authLoginRequest);

                            if (!mounted) return;

                            if (success) {
                              authVM.setLoggedIn();
                            }
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('ENTRAR'),
                        ),
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

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}
