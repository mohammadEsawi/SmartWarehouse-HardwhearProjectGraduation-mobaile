import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/screens/dashboard_screen.dart';
import 'package:smart_warehouse_mobile/screens/cells_screen.dart';
import 'package:smart_warehouse_mobile/screens/products_screen.dart';
import 'package:smart_warehouse_mobile/screens/operations_screen.dart';
import 'package:smart_warehouse_mobile/screens/conveyor_screen.dart';
import 'package:smart_warehouse_mobile/widgets/status_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CellsScreen(),
    const ProductsScreen(),
    const OperationsScreen(),
    const ConveyorScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.grid_view_outlined),
      activeIcon: Icon(Icons.grid_view),
      label: 'Cells',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2_outlined),
      activeIcon: Icon(Icons.inventory_2),
      label: 'Products',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: 'Operations',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.conveyor_belt_outlined),
      activeIcon: Icon(Icons.conveyor_belt),
      label: 'Conveyor',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final provider = Provider.of<WarehouseProvider>(context, listen: false);
      await provider.loadInitialData();
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading Smart Warehouse...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Warehouse'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshData();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuSelection(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'auto_mode',
                  child: Row(
                    children: [
                      Icon(Icons.auto_mode, size: 20),
                      SizedBox(width: 8),
                      Text('Auto Mode'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'manual_mode',
                  child: Row(
                    children: [
                      Icon(Icons.manual_mode, size: 20),
                      SizedBox(width: 8),
                      Text('Manual Mode'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'add_task',
                  child: Row(
                    children: [
                      Icon(Icons.add_task, size: 20),
                      SizedBox(width: 8),
                      Text('Add Task'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_tasks',
                  child: Row(
                    children: [
                      Icon(Icons.task, size: 20),
                      SizedBox(width: 8),
                      Text('View Tasks'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text('About'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StatusBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        elevation: 8,
        items: _navItems,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    final provider = Provider.of<WarehouseProvider>(context);
    
    if (_selectedIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () {
          _toggleAutoMode(provider);
        },
        icon: Icon(
          provider.isAutoMode ? Icons.stop : Icons.play_arrow,
        ),
        label: Text(provider.isAutoMode ? 'Stop Auto' : 'Start Auto'),
        backgroundColor: provider.isAutoMode ? Colors.red : Colors.green,
      );
    } else if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          _showAddProductDialog();
        },
        child: const Icon(Icons.add),
      );
    }
    
    return null;
  }

  Future<void> _toggleAutoMode(WarehouseProvider provider) async {
    try {
      final newMode = provider.isAutoMode ? 'manual' : 'auto';
      await provider.switchMode(newMode);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to $newMode mode'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch mode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    try {
      final provider = Provider.of<WarehouseProvider>(context, listen: false);
      await provider.refreshData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refresh failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'auto_mode':
        _toggleAutoMode(Provider.of<WarehouseProvider>(context, listen: false));
        break;
      case 'manual_mode':
        _toggleAutoMode(Provider.of<WarehouseProvider>(context, listen: false));
        break;
      case 'add_task':
        Navigator.pushNamed(context, '/tasks');
        break;
      case 'view_tasks':
        // TODO: Implement view tasks
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This feature is coming soon!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Warehouse Mobile',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Smart Warehouse System',
    );
  }
}