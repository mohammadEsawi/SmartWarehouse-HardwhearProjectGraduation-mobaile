import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:smart_warehouse_mobile/core/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;

  Stream<Map<String, dynamic>> get stream => _messageController.stream;
  bool get isConnected => _isConnected;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.wsUrl),
        protocols: ['smart-warehouse'],
      );

      _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _messageController.add({'type': 'connection', 'status': 'connected'});
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        final Map<String, dynamic> data = jsonDecode(message);
        _messageController.add(data);
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _messageController.add({'type': 'connection', 'status': 'error'});
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _messageController.add({'type': 'connection', 'status': 'disconnected'});
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    _reconnectTimer = Timer(delay, () {
      print('Attempting to reconnect... (attempt $_reconnectAttempts)');
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    }
  }

  void requestSensorData() {
    sendMessage({
      'type': 'request_sensor_data',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void requestWarehouseData() {
    sendMessage({
      'type': 'refresh_data',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void disconnect() {
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
    }

    if (_channel != null) {
      _channel!.sink.close();
    }

    _messageController.close();
    _isConnected = false;
  }

  void reconnect() {
    disconnect();
    _reconnectAttempts = 0;
    connect();
  }
}