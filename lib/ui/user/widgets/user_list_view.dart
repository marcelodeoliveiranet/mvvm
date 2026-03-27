import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/view_model/auth_login_viewmodel.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/utils/view_model_state.dart';
import 'package:provider/provider.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    void confirmDelete(BuildContext context, UserViewModel vm, int userId) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Excluir Usuário"),
          content: const Text("Deseja realmente excluir?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                vm.deleteUser(userId);
              },
              child: const Text("Excluir"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuários Cadastrados"),
        actions: [
          IconButton(
            onPressed: () async {
              final vm = context.read<AuthLoginViewModel>();
              await vm.logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),

      body: Consumer<UserViewModel>(
        builder: (context, vm, child) {
          if (vm.state == ViewModelState.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.loadUsers,
                    child: const Text("Tentar novamente"),
                  ),
                ],
              ),
            );
          }

          if (vm.users.isEmpty) {
            return Center(child: const Text("Nenhum usuário cadastrado"));
          }

          return RefreshIndicator(
            onRefresh: vm.loadUsers,
            child: ListView.builder(
              itemCount: vm.users.length,
              itemBuilder: (context, index) {
                final user = vm.users[index];

                return ListTile(
                  leading: CircleAvatar(child: Text(user.nome[0])),
                  title: Text(user.nome),
                  subtitle: Text(user.email),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await context.push(
                            AppRoutes.userForm,
                            extra: {'user': user},
                          );

                          if (!context.mounted) return;

                          if (result == true) {
                            context.read<UserViewModel>().loadUsers();
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          confirmDelete(context, vm, user.id!);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(AppRoutes.userForm);

          if (!context.mounted) return;

          if (result == true) {
            context.read<UserViewModel>().loadUsers();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
