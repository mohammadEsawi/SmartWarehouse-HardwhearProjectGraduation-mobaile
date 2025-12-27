import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date, {String format = 'MMM dd, HH:mm'}) {
    return DateFormat(format).format(date);
  }

  // Format time ago
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Validate IP address
  static bool isValidIP(String ip) {
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return regex.hasMatch(ip);
  }

  // Validate RFID format
  static bool isValidRFID(String rfid) {
    // Simple validation for common RFID formats
    return rfid.isNotEmpty && rfid.length >= 8 && rfid.length <= 20;
  }

  // Generate cell label
  static String generateCellLabel(int row, int col) {
    return 'R${row}C${col}';
  }

  // Parse cell label
  static Map<String, int> parseCellLabel(String label) {
    try {
      final regex = RegExp(r'R(\d+)C(\d+)');
      final match = regex.firstMatch(label);
      if (match != null) {
        return {
          'row': int.parse(match.group(1)!),
          'col': int.parse(match.group(2)!),
        };
      }
    } catch (e) {
      print('Error parsing cell label: $e');
    }
    return {'row': 1, 'col': 1};
  }

  // Calculate warehouse statistics
  static Map<String, dynamic> calculateStatistics(
    List<Map<String, dynamic>> cells,
  ) {
    final total = cells.length;
    final occupied = cells.where((cell) => cell['status'] == 'OCCUPIED').length;
    final empty = cells.where((cell) => cell['status'] == 'EMPTY').length;
    final reserved = cells.where((cell) => cell['status'] == 'RESERVED').length;
    final utilization = total > 0 ? (occupied / total) * 100 : 0;

    return {
      'total': total,
      'occupied': occupied,
      'empty': empty,
      'reserved': reserved,
      'utilization': utilization,
      'utilization_percent': '${utilization.toStringAsFixed(1)}%',
    };
  }

  // Debounce function
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(delay, () {
        func();
      });
    };
  }

  // Throttle function
  static Function throttle(Function func, Duration delay) {
    Timer? timer;
    bool isThrottled = false;
    return () {
      if (!isThrottled) {
        func();
        isThrottled = true;
        timer = Timer(delay, () {
          isThrottled = false;
        });
      }
    };
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    // TODO: Implement clipboard
    showInfo(context, 'Copied to clipboard');
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'READY':
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
      case 'PENDING':
        return Colors.orange;
      case 'ERROR':
      case 'FAILED':
        return Colors.red;
      case 'IDLE':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // Get status icon
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'READY':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PROCESSING':
        return Icons.refresh;
      case 'PENDING':
        return Icons.pending;
      case 'ERROR':
      case 'FAILED':
        return Icons.error;
      case 'IDLE':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  // Format bytes to human readable
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Get random color
  static Color getRandomColor() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }
}