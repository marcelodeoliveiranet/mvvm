import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/view_model/auth_login_viewmodel.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final loadCmd = context.watch<UserViewModel>().loadUsersCommand;

    //Primeira execução
    //Se eu entendi direito esta linha Future.microtask faz o seguinte
    //execute isso logo depois que o build atual terminar
    //Sem esta linha as vezes ela mostrava um tela em branco ou a mensagem
    //nenhum usuario cadastrado e depois mostrava os usuarios cadastrados
    if (!loadCmd.running && loadCmd.result == null) {
      Future.microtask(loadCmd.execute);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuários Cadastrados"),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthLoginViewModel>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (loadCmd.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (loadCmd.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loadCmd.result.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadCmd.execute,
                    child: const Text("Tentar novamente"),
                  ),
                ],
              ),
            );
          }

          if (loadCmd.result == null) {
            return const SizedBox();
          }

          if (vm.users.isEmpty) {
            return const Center(child: Text("Nenhum usuário cadastrado"));
          }

          // 🔹 Sucesso
          return RefreshIndicator(
            onRefresh: loadCmd.execute,
            child: Selector<UserViewModel, List<User>>(
              selector: (_, vm) => vm.users,
              builder: (_, users, _) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final deleteCmd = vm.deleteUserCommand;

                    return ListTile(
                      leading: CircleAvatar(child: Text(user.nome[0])),
                      title: Text(user.nome),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✏️ Editar
                          IconButton(
                            onPressed: () async {
                              final result = await context.push(
                                AppRoutes.userForm,
                                extra: {'user': user},
                              );

                              if (!context.mounted) return;

                              if (result == true) {
                                loadCmd.execute();
                                //vm.loadUsersCommand.execute();
                              }
                            },
                            icon: const Icon(Icons.edit),
                          ),

                          // 🗑️ Excluir
                          IconButton(
                            onPressed: deleteCmd.running
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Excluir Usuário"),
                                        content: const Text(
                                          "Deseja realmente excluir?",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text(
                                              "Cancelar",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deleteCmd.execute(user.id!);
                                            },
                                            child: const Text(
                                              "Excluir",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            icon: deleteCmd.running
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
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
            loadCmd.execute();
            //context.read<UserViewModel>().loadUsersCommand.execute();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
