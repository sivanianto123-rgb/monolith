import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Opt-in only: previously this was gated on `kDebugMode`, which meant
/// *every* debug run — including a plain `flutter run -d chrome` against a
/// real, configured Firebase project — silently tried to talk to
/// `localhost:9099`/`:8080` instead. With no emulator listening there, every
/// auth/Firestore call failed with a connection-refused style error (and,
/// for Google sign-in's popup flow specifically, the popup would navigate to
/// the emulator's dead OAuth handler URL and hang forever waiting for a
/// response that never comes). Emulators are now only used when explicitly
/// requested via `flutter run -d chrome --dart-define=USE_FIREBASE_EMULATOR=true`
/// *and* `firebase emulators:start` is actually running.
const _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(const ProviderScope(child: MonolithApp()));
}

class MonolithApp extends ConsumerWidget {
  const MonolithApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Monolith',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
