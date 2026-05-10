import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteConstants {
  static const String home = '/home';
  static const String loanDashboard = '/loan-dashboard';
  static const String loanApplications = '/loan-applications';
  static const String addLoan = '/add-loan';
  static const String profile = '/profile';
  static const String chatbot = '/chatbot';
}

class AppRouter {
  static Future<GoRouter> initRouter(FutureProviderRef<GoRouter> ref) async {
    // Wait for auth state to be initialized before creating router
    final authStateNotifier = ref.read(authStateProvider.notifier);

    // Ensure auth state is initialized
    int maxWaitTime = 30; // Maximum 3 seconds wait
    while (!ref.read(authStateProvider).isInitialized && maxWaitTime > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
      maxWaitTime--;
    }

    debugPrint('Router: Auth state initialized, creating router');
    // /doctor/home
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: isDev ? '/doctor/home' : '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.splash,
          path: '/',
          builder: (context, state) => const MainSplashScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.onboarding,
          path: '/onboarding',
          builder: (context, state) => OnboardingScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.role,
          path: '/role',
          builder: (context, state) => RoleScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.signUp,
          path: '/sign-up',
          builder: (context, state) =>
              AuthMiddleware(requiresAuth: false, child: const SignUpScreen()),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.login,
          path: '/login',
          builder: (context, state) =>
              AuthMiddleware(requiresAuth: false, child: const LoginScreen()),
          routes: [
            GoRoute(
              name: RouteConstants.forgotPass,
              path: 'forgot-password',
              builder: (context, state) => AuthMiddleware(
                requiresAuth: false,
                child: const ForgotPasswordScreen(),
              ),
              routes: [
                GoRoute(
                  name: RouteConstants.passReset,
                  path: 'password-reset',
                  builder: (context, state) => AuthMiddleware(
                    requiresAuth: false,
                    child: PasswordInputScreen(),
                  ),
                ),
              ],
            ),
            GoRoute(
              name: RouteConstants.otp,
              path: 'otp',
              builder: (context, state) =>
                  AuthMiddleware(requiresAuth: false, child: const OtpScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/contactUs',
          name: RouteConstants.contactUs,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: true,
            child: const ContactUsScreen(),
          ),
        ),
        GoRoute(
          path: '/reportProblem',
          name: RouteConstants.reportProblem,
          builder: (context, state) => AuthMiddleware(
            requiresAuth: true,
            child: const ReportAProblemScreen(),
          ),
        ),
        GoRoute(
          path: '/scan-qr',
          parentNavigatorKey: rootNavigatorKey,
          name: RouteConstants.qrScan,
          builder: (context, state) => ScanQR(),
        ),
        ...patientRoutes,
        ...doctorRoutes,
      ],
      redirect: (context, state) => _handleRedirect(context, state, ref),
      refreshListenable: EnhancedGoRouterRefreshStream(
        ref.read(authStateProvider.notifier).stream,
      ),
    );
  }

  // Enhanced redirect logic with better authentication handling
  static String? _handleRedirect(
    BuildContext context,
    GoRouterState state,
    FutureProviderRef<GoRouter> ref,
  ) {
    final auth = ref.read(authStateProvider);
    final currentLocation = state.matchedLocation;

    debugPrint('Router: Redirect check for $currentLocation');
    debugPrint(
      'Router: Auth state - isAuthenticated: ${auth.isAuthenticated}, role: ${auth.userRole}, initialized: ${auth.isInitialized}',
    );

    // If in dev mode, allow all navigation
    if (isDev) {
      debugPrint('Router: Dev mode - allowing navigation to $currentLocation');
      return null;
    }

    // Wait for auth state to be initialized
    if (!auth.isInitialized) {
      debugPrint('Router: Auth state not initialized, staying on splash');
      return currentLocation == '/' ? null : '/';
    }

    // Define auth-related routes
    final authRoutes = {'/login', '/sign-up', '/onboarding', '/role'};

    final isGoingToAuthRoute = authRoutes.any(
      (route) => currentLocation.startsWith(route),
    );

    // Allow access to splash screen always
    if (currentLocation == '/') {
      debugPrint('Router: Allowing access to splash screen');
      return null;
    }

    // Handle authenticated users trying to access auth routes
    if (auth.isAuthenticated && isGoingToAuthRoute) {
      final redirectTo = auth.userRole == 'Doctor' ? '/doctor/home' : '/home';
      debugPrint(
        'Router: Authenticated user accessing auth route, redirecting to $redirectTo',
      );
      return redirectTo;
    }

    // Handle unauthenticated users trying to access protected routes
    if (!auth.isAuthenticated &&
        !isGoingToAuthRoute &&
        currentLocation != '/') {
      debugPrint(
        'Router: Unauthenticated user accessing protected route, redirecting to /role',
      );
      return '/role';
    }

    // Special handling for role-specific routes
    if (auth.isAuthenticated && auth.userRole != null) {
      // Doctors trying to access patient routes
      if (auth.userRole == 'Doctor' && currentLocation.startsWith('/home')) {
        debugPrint(
          'Router: Doctor accessing patient route, redirecting to doctor home',
        );
        return '/doctor/home';
      }

      // Patients trying to access doctor routes
      if (auth.userRole != 'Doctor' && currentLocation.startsWith('/doctor')) {
        debugPrint(
          'Router: Patient accessing doctor route, redirecting to patient home',
        );
        return '/home';
      }
    }

    debugPrint('Router: No redirect needed for $currentLocation');
    return null;
  }
}

// Enhanced refresh stream with better error handling and logging
class EnhancedGoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  bool _disposed = false;

  EnhancedGoRouterRefreshStream(Stream<AuthState> stream) {
    debugPrint('Router: Setting up auth state listener');

    // Initial notification
    notifyListeners();

    // Listen to auth state changes
    _subscription = stream.asBroadcastStream().listen(
      (authState) {
        if (!_disposed) {
          debugPrint('Router: Auth state changed - notifying router');
          debugPrint(
            'Router: New auth state - isAuthenticated: ${authState.isAuthenticated}, role: ${authState.userRole}',
          );
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Router: Error in auth state stream: $error');
        if (!_disposed) {
          notifyListeners(); // Still notify to trigger redirect logic
        }
      },
      onDone: () {
        debugPrint('Router: Auth state stream closed');
      },
    );
  }

  @override
  void dispose() {
    if (!_disposed) {
      debugPrint('Router: Disposing auth state listener');
      _disposed = true;
      _subscription.cancel();
      super.dispose();
    }
  }
}

// Legacy class for backwards compatibility
class GoRouterRefreshStream extends EnhancedGoRouterRefreshStream {
  GoRouterRefreshStream(Stream<dynamic> stream)
    : super(stream as Stream<AuthState>);
}

// Enhanced router provider with better error handling
final routerFutureProvider = FutureProvider<GoRouter>((ref) async {
  try {
    debugPrint('Router: Initializing router...');
    final router = await AppRouter.initRouter(ref);
    debugPrint('Router: Router initialized successfully');
    return router;
  } catch (e, stackTrace) {
    debugPrint('Router: Error initializing router: $e');
    debugPrint('Router: Stack trace: $stackTrace');
    rethrow;
  }
});

// Provider to check if router is ready
final routerReadyProvider = Provider<bool>((ref) {
  final routerAsync = ref.watch(routerFutureProvider);
  return routerAsync.hasValue;
});

// Provider to get router error if any
final routerErrorProvider = Provider<String?>((ref) {
  final routerAsync = ref.watch(routerFutureProvider);
  return routerAsync.hasError ? routerAsync.error.toString() : null;
});
