import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/state/auth_provider.dart';
import '../../core/state/cart_provider.dart';
import '../../core/theme/app_colors.dart';

const double kHeaderBreakpoint = 860;

class Header extends ConsumerStatefulWidget {
  const Header({super.key});

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  bool _menuOpen = false;

  static const _navLinks = [
    ('Shop', '/shop'),
    ('Customize', '/customize'),
    ('About', '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < kHeaderBreakpoint;
    final cartCount = ref.watch(cartItemCountProvider);
    final isSignedIn = ref.watch(authStateProvider).valueOrNull != null;
    final location = GoRouterState.of(context).uri.toString();

    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    'Monolith',
                    style: GoogleFonts.archivo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.02 * 22,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isCompact) ...[
                  for (final link in _navLinks)
                    _NavLink(
                      label: link.$1,
                      path: link.$2,
                      active: location.startsWith(link.$2),
                    ),
                  const SizedBox(width: 12),
                ],
                IconButton(
                  tooltip: isSignedIn ? 'Your orders' : 'Sign in',
                  icon: const Icon(
                    Icons.person_outline,
                    color: AppColors.foreground,
                  ),
                  onPressed: () => context.go(isSignedIn ? '/orders' : '/auth'),
                ),
                if (isSignedIn)
                  IconButton(
                    tooltip: 'Sign out',
                    icon: const Icon(Icons.logout, color: AppColors.foreground),
                    onPressed: () => ref.read(authServiceProvider).signOut(),
                  ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Bag',
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.foreground,
                      ),
                      onPressed: () => context.go('/cart'),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$cartCount',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivo(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isCompact)
                  IconButton(
                    tooltip: 'Menu',
                    icon: Icon(
                      _menuOpen ? Icons.close : Icons.menu,
                      color: AppColors.foreground,
                    ),
                    onPressed: () => setState(() => _menuOpen = !_menuOpen),
                  ),
              ],
            ),
          ),
          if (isCompact && _menuOpen)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final link in _navLinks)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _menuOpen = false);
                          context.go(link.$2);
                        },
                        child: Text(
                          link.$1,
                          style: GoogleFonts.archivo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String path;
  final bool active;

  const _NavLink({
    required this.label,
    required this.path,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Text(
          label,
          style: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.foreground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
