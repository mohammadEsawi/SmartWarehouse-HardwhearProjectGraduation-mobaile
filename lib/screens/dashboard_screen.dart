import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/widgets/stats_card.dart';
import 'package:smart_warehouse_mobile/widgets/conveyor_widget.dart';
import 'package:smart_warehouse_mobile/widgets/control_panel.dart';
import 'package:smart_warehouse_mobile/widgets/cell_grid.dart';
import 'package:smart_warehouse_mobile/widgets/task_queue_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refreshData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total Cells',
                    value: provider.totalCells.toString(),
                    icon: Icons.grid_view,
                    color: Colors.blue,
                    subtitle: '${AppConstants.totalRows}x${AppConstants.totalColumns}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Occupied',
                    value: provider.occupiedCells.toString(),
                    icon: Icons.inventory,
                    color: Colors.green,
                    subtitle: '${((provider.occupiedCells / provider.totalCells) * 100).toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Available',
                    value: provider.availableCells.toString(),
                    icon: Icons.space_dashboard,
                    color: Colors.orange,
                    subtitle: 'Free spaces',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Conveyor Status
            ConveyorWidget(
              hasProduct: provider.conveyorHasProduct,
              productName: provider.conveyorProductName,
              rfidTag: provider.currentRFID,
              ldr1Active: provider.ldr1Active,
              ldr2Active: provider.ldr2Active,
              onTap: () {
                Navigator.pushNamed(context, '/conveyor');
              },
            ),
            
            const SizedBox(height: 20),
            
            // Mode Control Card
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
                          'Operation Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            provider.isAutoMode ? 'AUTO' : 'MANUAL',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: provider.isAutoMode
                              ? Colors.deepPurple
                              : Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              provider.switchMode('manual');
                            },
                            icon: const Icon(Icons.manual_mode),
                            label: const Text('Manual'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: !provider.isAutoMode
                                  ? Colors.blue
                                  : Colors.grey,
                              side: BorderSide(
                                color: !provider.isAutoMode
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              provider.switchMode('auto');
                            },
                            icon: const Icon(Icons.auto_mode),
                            label: const Text('Auto'),
                            style: FilledButton.styleFrom(
                              backgroundColor: provider.isAutoMode
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick Control Panel
            const ControlPanel(),
            
            const SizedBox(height: 20),
            
            // Task Queue
            TaskQueueWidget(
              tasks: provider.autoTasks,
              onTaskTap: (taskId) {
                // Handle task tap
              },
            ),
            
            const SizedBox(height: 20),
            
            // Warehouse Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Warehouse Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cells');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            CellGrid(
              cells: provider.cells.take(8).toList(),
              onCellTap: (cell) {
                Navigator.pushNamed(
                  context,
                  '/cellDetail',
                  arguments: {
                    'cellId': cell.id,
                    'cellLabel': cell.label,
                  },
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Loading Zone Status
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
                      'Loading Zone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          provider.loadingZoneProductId != null
                              ? Icons.inventory
                              : Icons.inventory_2,
                          color: provider.loadingZoneProductId != null
                              ? Colors.green
                              : Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.loadingZoneProductId != null
                                    ? provider.loadingZoneProductName ?? 'Product'
                                    : 'Empty',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantity: ${provider.loadingZoneQuantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Clear loading zone
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}