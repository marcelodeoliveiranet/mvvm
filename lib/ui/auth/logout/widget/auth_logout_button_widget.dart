import 'package:flutter/material.dart';
import 'package:mvvm/ui/auth/logout/view_model/logout_viewmodel.dart';

class AuthLogoutButtonWidget extends StatefulWidget {
  final LogoutViewmodel logoutViewmodel;
  const AuthLogoutButtonWidget({super.key, required this.logoutViewmodel});

  @override
  State<AuthLogoutButtonWidget> createState() => _AuthLogoutButtonWidgetState();
}

class _AuthLogoutButtonWidgetState extends State<AuthLogoutButtonWidget> {
  @override
  void initState() {
    super.initState();
    widget.logoutViewmodel.logoutCommand.addListener(onResult);
  }

  @override
  void didUpdateWidget(covariant AuthLogoutButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.logoutViewmodel.logoutCommand.removeListener(onResult);
    widget.logoutViewmodel.logoutCommand.addListener(onResult);
  }

  void onResult() {
    if (widget.logoutViewmodel.logoutCommand.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Houve um erro ao realizar o logout"),
          action: SnackBarAction(
            label: "Tente novamente",
            onPressed: widget.logoutViewmodel.logoutCommand.execute,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void dispose() {
    widget.logoutViewmodel.logoutCommand.removeListener(onResult);
    super.dispose();
  }
}
