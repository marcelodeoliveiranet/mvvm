import 'package:flutter/material.dart';
import 'package:mvvm/ui/user/view_model/user_view_model.dart';
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
      appBar: AppBar(title: const Text("Usuários Cadastrados")),
      body: Consumer<UserViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
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

                  trailing: IconButton(
                    onPressed: () {
                      confirmDelete(context, vm, user.id);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
