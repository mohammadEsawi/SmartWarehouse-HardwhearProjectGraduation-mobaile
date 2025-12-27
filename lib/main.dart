import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/core/routes.dart';
import 'package:smart_warehouse_mobile/core/theme.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/services/api_service.dart';
import 'package:smart_warehouse_mobile/services/websocket_service.dart';
import 'package:smart_warehouse_mobile/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartWarehouseApp());
}

class SmartWarehouseApp extends StatelessWidget {
  const SmartWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WarehouseProvider()),
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Smart Warehouse',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.home,
        onGenerateRoute: Routes.generateRoute,
        home: const HomeScreen(),
      ),
    );
  }
}