import 'package:go_router/go_router.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/view_model/auth_login_viewmodel.dart';
import 'package:mvvm/ui/auth/view_model/auth_view_model.dart';
import 'package:mvvm/ui/auth/widgets/auth_login.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/user/widgets/user_list_page.dart';
import 'package:mvvm/ui/user/widgets/user_form_page.dart';
import 'package:provider/provider.dart';

GoRouter createRouter({
  required AuthViewModel authViewModel,
  required AuthRepository authRepository,
}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    refreshListenable: authViewModel,

    redirect: (context, state) {
      final isLoggedIn = authViewModel.isLoggedIn;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isGoingToLogin) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isGoingToLogin) {
        return AppRoutes.userList;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: authViewModel),

              ChangeNotifierProvider(
                create: (_) => AuthLoginViewModel(
                  authRepository: authRepository,
                  authViewModel: authViewModel,
                ),
              ),
            ],
            child: const AuthLogin(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.userList,
        builder: (context, state) {
          return const UserListPage();
        },
      ),

      GoRoute(
        path: AppRoutes.userForm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final user = extra?['user'];
          return UserFormPage(
            userViewModel: context.read<UserViewModel>(),
            user: user,
          );
        },
      ),
    ],
  );
}
