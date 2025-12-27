class AppConstants {
  // API URLs
  static const String baseUrl = 'http://192.168.1.100:5001';
  static const String wsUrl = 'ws://192.168.1.100:5001/ws';
  
  // ESP32 Configuration
  static const String esp32BaseUrl = 'http://192.168.1.101';
  
  // Database
  static const String dbName = 'smart_warehouse.db';
  static const int dbVersion = 1;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration wsReconnectDelay = Duration(seconds: 3);
  
  // Warehouse Configuration
  static const int totalRows = 3;
  static const int totalColumns = 4;
  static const int totalCells = totalRows * totalColumns;
  
  // Status Messages
  static const Map<String, String> statusMessages = {
    'READY': 'Ready',
    'PROCESSING': 'Processing...',
    'ERROR': 'Error',
    'COMPLETED': 'Completed',
    'IDLE': 'Idle',
    'BUSY': 'Busy',
    'CONNECTED': 'Connected',
    'DISCONNECTED': 'Disconnected',
  };
  
  // Status Colors
  static const Map<String, Color> statusColors = {
    'READY': Colors.green,
    'PROCESSING': Colors.orange,
    'ERROR': Colors.red,
    'COMPLETED': Colors.blue,
    'IDLE': Colors.grey,
    'BUSY': Colors.amber,
    'CONNECTED': Colors.green,
    'DISCONNECTED': Colors.red,
  };
  
  // Operation Types
  static const List<String> operationTypes = [
    'HOME',
    'PICK_FROM_CONVEYOR',
    'PLACE_IN_CELL',
    'TAKE_FROM_CELL',
    'GOTO_COLUMN',
    'MANUAL_CMD',
    'MOVE_TO_LOADING',
    'RETURN_TO_LOADING',
    'AUTO_STOCK',
    'AUTO_RETRIEVE',
  ];
  
  // Task Types
  static const List<String> taskTypes = [
    'STOCK',
    'RETRIEVE',
    'MOVE',
    'ORGANIZE',
    'INVENTORY_CHECK',
  ];
  
  // Sensor Types
  static const List<String> sensorTypes = [
    'LDR1',
    'LDR2',
    'RFID',
    'ULTRASONIC',
    'LIMIT_SWITCH',
  ];
  
  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Tools',
    'Components',
    'Materials',
    'Packaging',
    'Other',
  ];
  
  // Priority Levels
  static const List<String> priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  
  // Default Ports
  static const int webServerPort = 80;
  static const int apiServerPort = 5001;
  
  // App Version
  static const String appVersion = '1.0.0';
  static const String appName = 'Smart Warehouse Mobile';
}