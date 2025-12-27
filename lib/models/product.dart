import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String? sku;
  final String? rfidUid;
  final String? category;
  final int? weightGrams;
  final bool autoAssign;
  final int occupiedCells;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.rfidUid,
    this.category,
    this.weightGrams,
    this.autoAssign = true,
    this.occupiedCells = 0,
    this.totalQuantity = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      rfidUid: json['rfid_uid'] as String?,
      category: json['category'] as String?,
      weightGrams: json['weight_grams'] as int?,
      autoAssign: json['auto_assign'] ?? true,
      occupiedCells: json['occupied_cells'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'rfid_uid': rfidUid,
      'category': category,
      'weight_grams': weightGrams,
      'auto_assign': autoAssign,
      'occupied_cells': occupiedCells,
      'total_quantity': totalQuantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (sku != null) {
      return '$name ($sku)';
    }
    return name;
  }

  Color get categoryColor {
    switch (category?.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'tools':
        return Colors.orange;
      case 'components':
        return Colors.green;
      case 'materials':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get categoryIcon {
    switch (category?.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'tools':
        return Icons.build;
      case 'components':
        return Icons.settings;
      case 'materials':
        return Icons.inventory;
      default:
        return Icons.category;
    }
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku)';
  }
}