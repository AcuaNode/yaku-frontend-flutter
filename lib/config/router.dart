import 'package:go_router/go_router.dart';
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
import '../presentation/pages/operator/operator_home_page.dart';
import '../presentation/pages/operator/operator_pond_detail_page.dart';
import '../presentation/pages/operator/operator_history_page.dart';
import '../presentation/pages/operator/operator_alerts_page.dart';
import '../presentation/pages/operator/operator_profile_page.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final isOperator = auth.user?.role == 'OPERATOR';
      final loc = state.matchedLocation;
      final isAuth = loc == '/login' || loc == '/register';

      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return isOperator ? '/op/home' : '/dashboard';

      // Enforce role separation: OPERATOR can't access admin routes and vice versa
      if (loggedIn && isOperator && !loc.startsWith('/op/')) return '/op/home';
      if (loggedIn && !isOperator && loc.startsWith('/op/')) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Admin routes
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

      // Operator mobile routes
      GoRoute(path: '/op/home', builder: (_, __) => const OperatorHomePage()),
      GoRoute(
        path: '/op/pond/:id',
        builder: (_, state) =>
            OperatorPondDetailPage(pondId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/op/history/:id',
        builder: (_, state) =>
            OperatorHistoryPage(pondId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/op/alerts', builder: (_, __) => const OperatorAlertsPage()),
      GoRoute(path: '/op/profile', builder: (_, __) => const OperatorProfilePage()),
    ],
    initialLocation: '/login',
  );
}
