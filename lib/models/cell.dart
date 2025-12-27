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
      id: json['id'],
      rowNum: json['row_num'],
      colNum: json['col_num'],
      label: json['label'],
      status: json['status'] ?? 'EMPTY',
      productId: json['product_id'],
      productName: json['product_name'],
      productSku: json['sku'],
      rfidUid: json['rfid_uid'],
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
}