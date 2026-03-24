import 'package:flutter/material.dart';
import 'package:mvvm/ui/user/view_model/user_view_model.dart';
import 'package:mvvm/ui/user/widgets/user_list_view.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserViewModel(context.read())..loadUsers(),
      child: const UserListView(),
    );
  }
}
