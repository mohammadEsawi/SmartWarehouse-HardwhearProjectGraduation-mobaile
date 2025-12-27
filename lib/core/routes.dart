import 'package:flutter/material.dart';
import 'package:smart_warehouse_mobile/screens/home_screen.dart';
import 'package:smart_warehouse_mobile/screens/dashboard_screen.dart';
import 'package:smart_warehouse_mobile/screens/cells_screen.dart';
import 'package:smart_warehouse_mobile/screens/products_screen.dart';
import 'package:smart_warehouse_mobile/screens/operations_screen.dart';
import 'package:smart_warehouse_mobile/screens/conveyor_screen.dart';
import 'package:smart_warehouse_mobile/screens/settings_screen.dart';
import 'package:smart_warehouse_mobile/screens/tasks_screen.dart';
import 'package:smart_warehouse_mobile/screens/cell_detail_screen.dart';

class Routes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String cells = '/cells';
  static const String cellDetail = '/cellDetail';
  static const String products = '/products';
  static const String operations = '/operations';
  static const String conveyor = '/conveyor';
  static const String settings = '/settings';
  static const String tasks = '/tasks';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case cells:
        return MaterialPageRoute(builder: (_) => const CellsScreen());
      case cellDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CellDetailScreen(
            cellId: args['cellId'],
            cellLabel: args['cellLabel'],
          ),
        );
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case operations:
        return MaterialPageRoute(builder: (_) => const OperationsScreen());
      case conveyor:
        return MaterialPageRoute(builder: (_) => const ConveyorScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case tasks:
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}