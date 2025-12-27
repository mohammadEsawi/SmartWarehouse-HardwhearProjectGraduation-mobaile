import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Operation {
  final int id;
  final String type;
  final String command;
  final String status; // PENDING, PROCESSING, COMPLETED, ERROR, CANCELLED
  final String? errorMessage;
  final int? productId;
  final String? productName;
  final int? cellId;
  final String? cellLabel;
  final int? executionTimeMs;
  final String priority; // LOW, MEDIUM, HIGH
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Operation({
    required this.id,
    required this.type,
    required this.command,
    required this.status,
    this.errorMessage,
    this.productId,
    this.productName,
    this.cellId,
    this.cellLabel,
    this.executionTimeMs,
    required this.priority,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] as int,
      type: json['op_type'] as String,
      command: json['cmd'] as String,
      status: json['status'] ?? 'PENDING',
      errorMessage: json['error_message'] as String?,
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String?,
      cellId: json['cell_id'] as int?,
      cellLabel: json['cell_label'] as String?,
      executionTimeMs: json['execution_time_ms'] as int?,
      priority: json['priority'] ?? 'MEDIUM',
      createdAt: DateTime.parse(json['created_at']),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  String get formattedTime {
    return DateFormat('HH:mm:ss').format(createdAt);
  }

  String get formattedDate {
    return DateFormat('MMM dd').format(createdAt);
  }

  Color get statusColor {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
        return Colors.orange;
      case 'ERROR':
        return Colors.red;
      case 'PENDING':
        return Colors.yellow;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PROCESSING':
        return Icons.refresh;
      case 'ERROR':
        return Icons.error;
      case 'PENDING':
        return Icons.pending;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String get executionTimeFormatted {
    if (executionTimeMs == null) return 'N/A';
    if (executionTimeMs! < 1000) {
      return '${executionTimeMs}ms';
    }
    return '${(executionTimeMs! / 1000).toStringAsFixed(2)}s';
  }

  bool get isActive => status == 'PROCESSING' || status == 'PENDING';

  @override
  String toString() {
    return 'Operation(id: $id, type: $type, status: $status)';
  }
}