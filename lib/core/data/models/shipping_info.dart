import 'package:flutter/foundation.dart';

@immutable
class ShippingInfo {
  final String fullName;
  final String email;
  final String address;
  final String city;
  final String postalCode;
  final String country;

  const ShippingInfo({
    required this.fullName,
    required this.email,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'country': country,
  };

  factory ShippingInfo.fromJson(Map<String, dynamic> json) => ShippingInfo(
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    address: json['address'] as String? ?? '',
    city: json['city'] as String? ?? '',
    postalCode: json['postalCode'] as String? ?? '',
    country: json['country'] as String? ?? '',
  );
}
