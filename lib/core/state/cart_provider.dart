import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/cart_item.dart';
import '../data/models/part_colors.dart';

const _kCartStorageKey = 'monolith.cart.v1';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCartStorageKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      // Corrupt/legacy local storage — start from an empty bag.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_kCartStorageKey, raw);
  }

  void add({
    required String slug,
    required String name,
    required String size,
    required double price,
    required bool isCustom,
    required PartColors colors,
    required String glbAsset,
    String? customName,
    int quantity = 1,
  }) {
    final key = CartItem.keyFor(
      slug: slug,
      size: size,
      isCustom: isCustom,
      colors: colors,
    );
    final existingIndex = state.indexWhere((i) => i.key == key);
    if (existingIndex != -1) {
      final existing = state[existingIndex];
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == existingIndex)
            existing.copyWith(quantity: existing.quantity + quantity)
          else
            state[i],
      ];
    } else {
      state = [
        ...state,
        CartItem(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          slug: slug,
          name: name,
          size: size,
          price: price,
          isCustom: isCustom,
          colors: colors,
          glbAsset: glbAsset,
          customName: customName,
          quantity: quantity,
        ),
      ];
    }
    _persist();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      remove(id);
      return;
    }
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(quantity: quantity) else item,
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((i) => i.id != id).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartProvider)
      .fold<double>(0, (sum, item) => sum + item.lineTotal);
});
