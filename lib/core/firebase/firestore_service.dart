import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/part_colors.dart';
import '../data/models/saved_design.dart';
import '../data/models/shipping_info.dart';

/// Typed access to `users/{uid}/savedDesigns` and `users/{uid}/orders`.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _designs(String uid) =>
      _db.collection('users').doc(uid).collection('savedDesigns');

  CollectionReference<Map<String, dynamic>> _orders(String uid) =>
      _db.collection('users').doc(uid).collection('orders');

  Future<void> saveDesign({
    required String uid,
    required String name,
    required String modelSlug,
    required PartColors colors,
  }) async {
    final doc = await _designs(uid).add({
      'name': name,
      'modelSlug': modelSlug,
      'colors': colors.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[Firestore] wrote design to: ${doc.path}');
  }

  Stream<List<SavedDesign>> listDesigns(String uid) {
    return _designs(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _designFromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteDesign(String uid, String designId) =>
      _designs(uid).doc(designId).delete();

  SavedDesign _designFromDoc(String id, Map<String, dynamic> data) {
    return SavedDesign(
      id: id,
      name: data['name'] as String? ?? 'My Monolith',
      modelSlug: data['modelSlug'] as String,
      colors: PartColors.fromJson(
        Map<String, dynamic>.from(data['colors'] as Map),
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<String> placeOrder({
    required String uid,
    required List<CartItem> items,
    required ShippingInfo shipping,
  }) async {
    final orderItems = items
        .map(
          (item) => OrderLineItem(
            slug: item.slug,
            name: item.name,
            size: item.size,
            quantity: item.quantity,
            priceCents: (item.price * 100).round(),
            custom: item.isCustom,
            colors: item.colors,
          ),
        )
        .toList();
    final totalCents = orderItems.fold<int>(
      0,
      (total, item) => total + item.priceCents * item.quantity,
    );

    final doc = await _orders(uid).add({
      'items': orderItems.map((item) => item.toJson()).toList(),
      'totalCents': totalCents,
      'shipping': shipping.toJson(),
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[Firestore] wrote order to: ${doc.path}');
    return doc.id;
  }

  Stream<List<OrderRecord>> listOrders(String uid) {
    return _orders(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _orderFromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  OrderRecord _orderFromDoc(String id, Map<String, dynamic> data) {
    return OrderRecord(
      id: id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'confirmed',
      totalCents: data['totalCents'] as int? ?? 0,
      shipping: ShippingInfo.fromJson(
        Map<String, dynamic>.from(data['shipping'] as Map),
      ),
      items: (data['items'] as List)
          .map(
            (e) => OrderLineItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}
