import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_warehouse_mobile/core/constants.dart';
import 'package:smart_warehouse_mobile/models/cell.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/models/operation.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  final http.Client _client = http.Client();

  Future<List<WarehouseCell>> fetchCells() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/cells'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WarehouseCell.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to load cells: $e');
    }
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/products'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<Operation>> fetchOperations({int limit = 20}) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/operations?limit=$limit'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Operation.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to load operations: $e');
    }
  }

  Future<Map<String, dynamic>> sendCommand({
    required String type,
    required String command,
    int? productId,
    int? cellId,
    String priority = 'MEDIUM',
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/operations'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'op_type': type,
              'cmd': command,
              'product_id': productId,
              'cell_id': cellId,
              'priority': priority,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }

  Future<void> switchMode(String mode) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/mode'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mode': mode}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to switch mode: $e');
    }
  }

  Future<void> addAutoTask({
    required String taskType,
    int? cellId,
    int? productId,
    String? productRfid,
    String priority = 'MEDIUM',
    int quantity = 1,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/auto-tasks'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'task_type': taskType,
              'cell_id': cellId,
              'product_id': productId,
              'product_rfid': productRfid,
              'priority': priority,
              'quantity': quantity,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<Map<String, dynamic>> getConveyorStatus() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/conveyor-status'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to get conveyor status: $e');
    }
  }

  Future<Map<String, dynamic>> getLoadingZone() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/loading-zone'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to get loading zone: $e');
    }
  }

  Future<List<dynamic>> getAutoTasks({String status = 'PENDING'}) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/auto-tasks?status=$status'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to get auto tasks: $e');
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/status'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to get status: $e');
    }
  }

  Future<void> assignProductToCell({
    required int cellId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/cells/$cellId/assign'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'product_id': productId,
              'quantity': quantity,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to assign product: $e');
    }
  }

  Future<void> createProduct({
    required String name,
    String? sku,
    String? rfidUid,
    String? category,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/products'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'sku': sku,
              'rfid_uid': rfidUid,
              'category': category,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> registerESP32(String ipAddress) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/esp32/register?ip=$ipAddress'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('Failed to register ESP32: $e');
    }
  }

  Exception _handleError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    switch (statusCode) {
      case 400:
        return Exception('Bad request: $body');
      case 401:
        return Exception('Unauthorized');
      case 403:
        return Exception('Forbidden');
      case 404:
        return Exception('Endpoint not found');
      case 500:
        return Exception('Server error: $body');
      default:
        return Exception('HTTP $statusCode: $body');
    }
  }

  void dispose() {
    _client.close();
  }
}