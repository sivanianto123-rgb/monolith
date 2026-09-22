import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/saved_design.dart';
import 'auth_provider.dart';

// autoDispose matters here, not just for memory: a plain (non-autoDispose)
// family provider is cached forever per uid, including its Firestore
// snapshots() subscription. If that listen ever fails with
// permission-denied (e.g. it started fetching a fresh ID token during a
// sign-out/sign-in transition and lost the race), cloud_firestore treats
// that as terminal and never retries the listener — so every future watch
// of that same uid would keep replaying the same cached error, even after
// the user is properly signed back in. autoDispose tears the provider (and
// its listener) down once the screen stops watching it, so returning to
// /orders after a fresh sign-in always opens a brand new listen.
final savedDesignsStreamProvider = StreamProvider.autoDispose
    .family<List<SavedDesign>, String>((ref, uid) {
      // Rebuild on every auth-state emission (not just a uid change) so a
      // fresh sign-in always opens a brand new Firestore listener instead
      // of potentially reusing one that raced the old session's token.
      ref.watch(authStateProvider);
      return ref.watch(firestoreServiceProvider).listDesigns(uid);
    });

final ordersStreamProvider = StreamProvider.autoDispose
    .family<List<OrderRecord>, String>((ref, uid) {
      ref.watch(authStateProvider);
      return ref.watch(firestoreServiceProvider).listOrders(uid);
    });
