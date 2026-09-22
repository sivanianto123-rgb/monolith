import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/customize/customize_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/product/product_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shop/shop_screen.dart';
import '../state/auth_provider.dart';

/// Paths that require a signed-in user. /orders and /checkout redirect to
/// `/auth?from=<original path>` when signed out, so the auth screen can send
/// the user back to where they meant to go once they sign in.
const _protectedPaths = ['/orders', '/checkout'];

/// Bridges the Firebase auth stream to go_router's [Listenable]-based
/// refresh mechanism, so a live sign-in/sign-out re-evaluates `redirect`
/// immediately instead of only on the next manual navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Every screen embeds one or more `<model-viewer>` elements, which Flutter
/// Web renders as real platform views (raw DOM), not Skia-painted content.
/// Platform views don't clip/composite reliably under an animated Navigator
/// transition, which mounts the outgoing and incoming pages together for
/// the crossfade/slide — that's what was letting the previous route's 3D
/// viewer and cards visually bleed through the next route. Routing with no
/// transition avoids ever having two routes' platform views mounted at once.
Page<void> _noTransitionPage(Widget child) {
  return NoTransitionPage(child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final refreshStream = GoRouterRefreshStream(authService.authStateChanges);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final signedIn = authService.currentUser != null;
      final isProtected = _protectedPaths.any(
        (path) => state.matchedLocation.startsWith(path),
      );
      if (isProtected && !signedIn) {
        final from = Uri.encodeComponent(state.uri.toString());
        return '/auth?from=$from';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _noTransitionPage(const HomeScreen()),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) =>
                _noTransitionPage(const ShopScreen()),
          ),
          GoRoute(
            path: '/product/:slug',
            pageBuilder: (context, state) => _noTransitionPage(
              ProductScreen(slug: state.pathParameters['slug']!),
            ),
          ),
          GoRoute(
            path: '/customize',
            pageBuilder: (context, state) => _noTransitionPage(
              CustomizeScreen(baseSlug: state.uri.queryParameters['base']),
            ),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                _noTransitionPage(const CartScreen()),
          ),
          GoRoute(
            path: '/checkout',
            pageBuilder: (context, state) =>
                _noTransitionPage(const CheckoutScreen()),
          ),
          GoRoute(
            path: '/auth',
            pageBuilder: (context, state) =>
                _noTransitionPage(const AuthScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                _noTransitionPage(const OrdersScreen()),
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) =>
                _noTransitionPage(const AboutScreen()),
          ),
        ],
      ),
    ],
  );
});
