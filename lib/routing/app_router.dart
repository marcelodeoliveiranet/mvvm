import 'package:go_router/go_router.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:mvvm/ui/auth/login/widgets/auth_login.dart';
import 'package:mvvm/ui/user/view_model/user_viewmodel.dart';
import 'package:mvvm/ui/user/widgets/user_form_page.dart';
import 'package:mvvm/ui/user/widgets/user_list_view.dart';
import 'package:provider/provider.dart';

GoRouter createRouter({required AuthRepository authRepository}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    refreshListenable: authRepository,

    redirect: (context, state) {
      final isLoggedIn = authRepository.isLoggedIn;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoinToUserForm = state.matchedLocation == AppRoutes.userForm;

      if (!isLoggedIn && !isGoingToLogin && isGoinToUserForm) {
        return AppRoutes.userForm;
      }

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
              Provider(
                create: (_) => LoginViewmodel(authRepository: authRepository),
              ),
            ],
            child: const AuthLogin(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.userList,
        builder: (context, state) {
          return const UserListView();
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
