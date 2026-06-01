import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../infrastructure/auth_provider.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/ponds_page.dart';
import '../presentation/pages/pond_detail_page.dart';
import '../presentation/pages/equipment_page.dart';
import '../presentation/pages/operators_page.dart';
import '../presentation/pages/notifications_page.dart';
import '../presentation/pages/settings_page.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    // redirect: (context, state) {
    //   final loggedIn = auth.isAuthenticated;
    //   final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    //   if (!loggedIn && !isAuth) return '/login';
    //   if (loggedIn && isAuth) return '/dashboard';
    //   return null;
    // },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/estanques', builder: (_, __) => const PondsPage()),
      GoRoute(
        path: '/estanques/:id',
        builder: (_, state) => PondDetailPage(pondId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/equipos', builder: (_, __) => const EquipmentPage()),
      GoRoute(path: '/operadores', builder: (_, __) => const OperatorsPage()),
      GoRoute(path: '/notificaciones', builder: (_, __) => const NotificationsPage()),
      GoRoute(path: '/configuracion', builder: (_, __) => const SettingsPage()),
    ],
    initialLocation: '/dashboard',
  );
}
