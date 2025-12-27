import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/widgets/conveyor_visualization.dart';
import 'package:smart_warehouse_mobile/widgets/sensor_indicator.dart';

class ConveyorScreen extends StatefulWidget {
  const ConveyorScreen({super.key});

  @override
  State<ConveyorScreen> createState() => _ConveyorScreenState();
}

class _ConveyorScreenState extends State<ConveyorScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoRefresh = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        Provider.of<WarehouseProvider>(context, listen: false).refreshData();
      });
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });
    
    if (_autoRefresh) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.refreshData();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Conveyor System',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleAutoRefresh,
                    icon: Icon(
                      _autoRefresh ? Icons.stop : Icons.play_arrow,
                    ),
                    tooltip: _autoRefresh ? 'Stop Auto Refresh' : 'Start Auto Refresh',
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Main Conveyor Visualization
              ConveyorVisualization(
                hasProduct: provider.conveyorHasProduct,
                productName: provider.conveyorProductName,
                rfidTag: provider.currentRFID,
                ldr1Active: provider.ldr1Active,
                ldr2Active: provider.ldr2Active,
                conveyorState: provider.conveyorState,
              ),
              
              const SizedBox(height: 30),
              
              // Sensor Status
              const Text(
                'Sensor Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  SensorIndicator(
                    sensorName: 'LDR1 - Entry',
                    isActive: provider.ldr1Active,
                    value: provider.ldr1Active ? 'DETECTED' : 'CLEAR',
                    icon: Icons.sensors,
                    color: provider.ldr1Active ? Colors.green : Colors.grey,
                  ),
                  SensorIndicator(
                    sensorName: 'LDR2 - Exit',
                    isActive: provider.ldr2Active,
                    value: provider.ldr2Active ? 'DETECTED' : 'CLEAR',
                    icon: Icons.sensors,
                    color: provider.ldr2Active ? Colors.green : Colors.grey,
                  ),
                  SensorIndicator(
                    sensorName: 'RFID Reader',
                    isActive: provider.currentRFID.isNotEmpty,
                    value: provider.currentRFID.isNotEmpty
                        ? 'READING'
                        : 'IDLE',
                    icon: Icons.qr_code_scanner,
                    color: provider.currentRFID.isNotEmpty
                        ? Colors.purple
                        : Colors.grey,
                  ),
                  SensorIndicator(
                    sensorName: 'Conveyor State',
                    isActive: provider.conveyorState != 'IDLE',
                    value: provider.conveyorState,
                    icon: Icons.conveyor_belt,
                    color: provider.conveyorState == 'IDLE'
                        ? Colors.grey
                        : provider.conveyorState == 'ERROR'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Product Information
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Product',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (provider.conveyorHasProduct) ...[
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.inventory,
                                  size: 32,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.conveyorProductName ?? 'Unknown Product',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (provider.currentRFID.isNotEmpty)
                                    Text(
                                      'RFID: ${provider.currentRFID}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Product detected on conveyor. Ready for processing.',
                          style: TextStyle(color: Colors.green),
                        ),
                      ] else ...[
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.conveyor_belt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No product on conveyor',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  _buildActionButton(
                    context,
                    'Pick from Conveyor',
                    Icons.arrow_downward,
                    Colors.blue,
                    () {
                      _pickFromConveyor(context);
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Auto Stock',
                    Icons.auto_mode,
                    Colors.green,
                    () {
                      _autoStock(context);
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Move Conveyor',
                    Icons.play_arrow,
                    Colors.orange,
                    () {
                      _moveConveyor(context);
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Stop Conveyor',
                    Icons.stop,
                    Colors.red,
                    () {
                      _stopConveyor(context);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Conveyor Log
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Clear log
                            },
                            icon: const Icon(Icons.clear_all),
                            tooltip: 'Clear Log',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildEventLog(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLog() {
    // TODO: Implement event log
    return const Column(
      children: [
        ListTile(
          leading: Icon(Icons.info, size: 16),
          title: Text('Conveyor started'),
          subtitle: Text('2 minutes ago'),
        ),
        ListTile(
          leading: Icon(Icons.check, size: 16, color: Colors.green),
          title: Text('Product detected by LDR1'),
          subtitle: Text('1 minute ago'),
        ),
        ListTile(
          leading: Icon(Icons.qr_code, size: 16, color: Colors.purple),
          title: Text('RFID tag read: 12.80.110.3'),
          subtitle: Text('30 seconds ago'),
        ),
      ],
    );
  }

  void _pickFromConveyor(BuildContext context) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.sendManualCommand(
        type: 'PICK_FROM_CONVEYOR',
        command: 'PICK',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick command sent to conveyor'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send pick command: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _autoStock(BuildContext context) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.addAutoTask(
        taskType: 'STOCK',
        priority: 'MEDIUM',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto stock task added to queue'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add auto stock task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _moveConveyor(BuildContext context) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.sendManualCommand(
        type: 'MANUAL_CMD',
        command: 'CONVEYOR_MOVE',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conveyor move command sent'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to move conveyor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopConveyor(BuildContext context) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.sendManualCommand(
        type: 'MANUAL_CMD',
        command: 'CONVEYOR_STOP',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conveyor stop command sent'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop conveyor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}