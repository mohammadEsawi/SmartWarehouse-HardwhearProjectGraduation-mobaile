import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    
    return Card(
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
              'Quick Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Mode Toggle
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
            
            const SizedBox(height: 16),
            
            // Control Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildControlButton(
                  context,
                  'Home Position',
                  Icons.home,
                  Colors.blue,
                  () {
                    _sendCommand(context, 'HOME', 'HOME');
                  },
                ),
                _buildControlButton(
                  context,
                  'Pick Conveyor',
                  Icons.arrow_downward,
                  Colors.green,
                  () {
                    _sendCommand(context, 'PICK_FROM_CONVEYOR', 'PICK');
                  },
                ),
                _buildControlButton(
                  context,
                  'Return Loading',
                  Icons.move_to_inbox,
                  Colors.orange,
                  () {
                    _sendCommand(context, 'RETURN_TO_LOADING', 'RETURN_TO_LOADING');
                  },
                ),
                _buildControlButton(
                  context,
                  'Auto Stock',
                  Icons.auto_mode,
                  Colors.purple,
                  () {
                    _addAutoTask(context, 'STOCK');
                  },
                ),
                _buildControlButton(
                  context,
                  'Move to Loading',
                  Icons.inventory,
                  Colors.teal,
                  () {
                    _showMoveToLoadingDialog(context);
                  },
                ),
                _buildControlButton(
                  context,
                  'Refresh Data',
                  Icons.refresh,
                  Colors.blueGrey,
                  () {
                    provider.refreshData();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Manual Command Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Manual command...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (command) {
                      if (command.isNotEmpty) {
                        _sendCommand(context, 'MANUAL_CMD', command);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    _showCommandHistory(context);
                  },
                  icon: const Icon(Icons.history),
                  tooltip: 'Command History',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _sendCommand(BuildContext context, String type, String command) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.sendManualCommand(
        type: type,
        command: command,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Command sent: $command'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send command: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addAutoTask(BuildContext context, String taskType) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.addAutoTask(
        taskType: taskType,
        priority: 'MEDIUM',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$taskType task added to queue'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMoveToLoadingDialog(BuildContext context) {
    // TODO: Implement move to loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select a cell first from the Cells screen'),
      ),
    );
  }

  void _showCommandHistory(BuildContext context) {
    // TODO: Implement command history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Command history coming soon'),
      ),
    );
  }
}