import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/models/operation.dart';
import 'package:intl/intl.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  String _filterStatus = 'ALL';
  String _filterType = 'ALL';
  int _limit = 50;
  bool _showErrorsOnly = false;

  final List<String> _statusFilters = [
    'ALL',
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'ERROR',
    'CANCELLED',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    List<Operation> filteredOperations = _filterOperations(provider.operations);

    return Scaffold(
      body: Column(
        children: [
          // Filter Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        items: _statusFilters.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterType,
                        items: [
                          'ALL',
                          ...AppConstants.operationTypes,
                        ].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.split('_').join(' ')),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filterType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filter by Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Errors Only'),
                      selected: _showErrorsOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showErrorsOnly = selected;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing ${filteredOperations.length} operations',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _showFilterOptions(context);
                      },
                      icon: const Icon(Icons.filter_alt),
                      tooltip: 'More Filters',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Operations List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.refreshData();
              },
              child: filteredOperations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No operations found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing your filters',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOperations.length,
                      itemBuilder: (context, index) {
                        final operation = filteredOperations[index];
                        return _buildOperationCard(context, operation);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendManualCommand(context);
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  List<Operation> _filterOperations(List<Operation> operations) {
    List<Operation> filtered = List.from(operations);

    // Apply status filter
    if (_filterStatus != 'ALL') {
      filtered =
          filtered.where((op) => op.status == _filterStatus).toList();
    }

    // Apply type filter
    if (_filterType != 'ALL') {
      filtered = filtered.where((op) => op.type == _filterType).toList();
    }

    // Apply errors only filter
    if (_showErrorsOnly) {
      filtered = filtered.where((op) => op.status == 'ERROR').toList();
    }

    // Apply limit
    if (filtered.length > _limit) {
      filtered = filtered.sublist(0, _limit);
    }

    return filtered;
  }

  Widget _buildOperationCard(BuildContext context, Operation operation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: operation.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            operation.statusIcon,
                            size: 14,
                            color: operation.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            operation.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: operation.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        operation.type.split('_').join(' '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  operation.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              operation.command,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                if (operation.cellLabel != null)
                  Chip(
                    label: Text(operation.cellLabel!),
                    backgroundColor: Colors.green.withOpacity(0.2),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (operation.productName != null) ...[
                  const SizedBox(width: 4),
                  Chip(
                    label: Text(operation.productName!),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const Spacer(),
                if (operation.executionTimeMs != null)
                  Text(
                    operation.executionTimeFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
            
            if (operation.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        operation.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  ListTile(
                    title: const Text('Number of Operations'),
                    subtitle: Text('Show $_limit operations'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_limit > 10) {
                              setState(() {
                                _limit -= 10;
                              });
                            }
                          },
                        ),
                        Text('$_limit'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_limit < 200) {
                              setState(() {
                                _limit += 10;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  SwitchListTile(
                    title: const Text('Show Only Errors'),
                    value: _showErrorsOnly,
                    onChanged: (value) {
                      setState(() {
                        _showErrorsOnly = value;
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _filterStatus = 'ALL';
                              _filterType = 'ALL';
                              _limit = 50;
                              _showErrorsOnly = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _sendManualCommand(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final commandController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Send Manual Command'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commandController,
                decoration: const InputDecoration(
                  labelText: 'Command',
                  hintText: 'e.g., HOME, PICK, PLACE 2 3',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Common commands: HOME, PICK, PLACE [col] [row], GOTO [col]',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final command = commandController.text.trim();
                if (command.isNotEmpty) {
                  _executeCommand(context, command);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _executeCommand(BuildContext context, String command) async {
    final provider = Provider.of<WarehouseProvider>(context, listen: false);
    
    try {
      await provider.sendManualCommand(
        type: 'MANUAL_CMD',
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
}