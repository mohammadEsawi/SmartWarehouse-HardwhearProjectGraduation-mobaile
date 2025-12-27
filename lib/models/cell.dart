import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WarehouseCell {
  final int id;
  final int rowNum;
  final int colNum;
  final String label;
  final String status; // EMPTY, OCCUPIED, RESERVED
  final int? productId;
  final String? productName;
  final String? productSku;
  final String? rfidUid;
  final int quantity;
  final DateTime updatedAt;
  bool isSelected;
  bool isLoading;

  WarehouseCell({
    required this.id,
    required this.rowNum,
    required this.colNum,
    required this.label,
    required this.status,
    this.productId,
    this.productName,
    this.productSku,
    this.rfidUid,
    this.quantity = 0,
    required this.updatedAt,
    this.isSelected = false,
    this.isLoading = false,
  });

  factory WarehouseCell.fromJson(Map<String, dynamic> json) {
    return WarehouseCell(
      id: json['id'] as int,
      rowNum: json['row_num'] as int,
      colNum: json['col_num'] as int,
      label: json['label'] as String,
      status: json['status'] ?? 'EMPTY',
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String?,
      productSku: json['sku'] as String?,
      rfidUid: json['rfid_uid'] as String?,
      quantity: json['quantity'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row_num': rowNum,
      'col_num': colNum,
      'label': label,
      'status': status,
      'product_id': productId,
      'product_name': productName,
      'sku': productSku,
      'rfid_uid': rfidUid,
      'quantity': quantity,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedUpdatedAt {
    return DateFormat('MMM dd, HH:mm').format(updatedAt);
  }

  Color get statusColor {
    switch (status) {
      case 'OCCUPIED':
        return const Color(0xFF10B981);
      case 'RESERVED':
        return const Color(0xFFF59E0B);
      case 'EMPTY':
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'OCCUPIED':
        return Icons.check_circle;
      case 'RESERVED':
        return Icons.access_time;
      case 'EMPTY':
      default:
        return Icons.crop_square;
    }
  }

  WarehouseCell copyWith({
    int? id,
    int? rowNum,
    int? colNum,
    String? label,
    String? status,
    int? productId,
    String? productName,
    String? productSku,
    String? rfidUid,
    int? quantity,
    DateTime? updatedAt,
    bool? isSelected,
    bool? isLoading,
  }) {
    return WarehouseCell(
      id: id ?? this.id,
      rowNum: rowNum ?? this.rowNum,
      colNum: colNum ?? this.colNum,
      label: label ?? this.label,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      rfidUid: rfidUid ?? this.rfidUid,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
      isSelected: isSelected ?? this.isSelected,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'WarehouseCell(id: $id, label: $label, status: $status, product: $productName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WarehouseCell && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}