import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/widgets/cell_widget.dart';
import 'package:smart_warehouse_mobile/models/cell.dart';

class CellsScreen extends StatefulWidget {
  const CellsScreen({super.key});

  @override
  State<CellsScreen> createState() => _CellsScreenState();
}

class _CellsScreenState extends State<CellsScreen> {
  String _filterStatus = 'ALL';
  String _sortBy = 'ROW';
  bool _showEmptyOnly = false;
  bool _showOccupiedOnly = false;

  final List<String> _statusFilters = ['ALL', 'EMPTY', 'OCCUPIED', 'RESERVED'];
  final List<String> _sortOptions = [
    'ROW',
    'COLUMN',
    'STATUS',
    'UPDATED',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    List<WarehouseCell> filteredCells = _filterCells(provider.cells);

    return Scaffold(
      body: Column(
        children: [
          // Filter and Sort Controls
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
                        value: _sortBy,
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
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
                      label: const Text('Empty Only'),
                      selected: _showEmptyOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showEmptyOnly = selected;
                          if (selected) _showOccupiedOnly = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Occupied Only'),
                      selected: _showOccupiedOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showOccupiedOnly = selected;
                          if (selected) _showEmptyOnly = false;
                        });
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${filteredCells.length} cells',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cells Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.refreshData();
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredCells.length,
                itemBuilder: (context, index) {
                  final cell = filteredCells[index];
                  return CellWidget(
                    cell: cell,
                    onTap: () {
                      _showCellDetails(context, cell);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<WarehouseCell> _filterCells(List<WarehouseCell> cells) {
    List<WarehouseCell> filtered = cells;

    // Apply status filter
    if (_filterStatus != 'ALL') {
      filtered = filtered.where((cell) => cell.status == _filterStatus).toList();
    }

    // Apply toggle filters
    if (_showEmptyOnly) {
      filtered = filtered.where((cell) => cell.status == 'EMPTY').toList();
    } else if (_showOccupiedOnly) {
      filtered = filtered.where((cell) => cell.status == 'OCCUPIED').toList();
    }

    // Apply sorting
    filtered = _sortCells(filtered);

    return filtered;
  }

  List<WarehouseCell> _sortCells(List<WarehouseCell> cells) {
    switch (_sortBy) {
      case 'ROW':
        cells.sort((a, b) {
          if (a.rowNum == b.rowNum) {
            return a.colNum.compareTo(b.colNum);
          }
          return a.rowNum.compareTo(b.rowNum);
        });
        break;
      case 'COLUMN':
        cells.sort((a, b) {
          if (a.colNum == b.colNum) {
            return a.rowNum.compareTo(b.rowNum);
          }
          return a.colNum.compareTo(b.colNum);
        });
        break;
      case 'STATUS':
        cells.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'UPDATED':
        cells.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    return cells;
  }

  void _showCellDetails(BuildContext context, WarehouseCell cell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cell.label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      cell.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: cell.statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Row: ${cell.rowNum}, Column: ${cell.colNum}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 20),
              
              if (cell.productId != null) ...[
                const Text(
                  'Product Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Product Name'),
                  subtitle: Text(cell.productName ?? 'Unknown'),
                ),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('SKU'),
                  subtitle: Text(cell.productSku ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('RFID'),
                  subtitle: Text(cell.rfidUid ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text('Quantity'),
                  subtitle: Text(cell.quantity.toString()),
                ),
              ] else ...[
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.crop_square,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Empty Cell',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No product assigned',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
              
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
                        _showCellActions(context, cell);
                      },
                      child: const Text('Actions'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCellActions(BuildContext context, WarehouseCell cell) {
    Navigator.pop(context); // Close details sheet
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Actions for ${cell.label}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              if (cell.status == 'EMPTY) ...[
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Assign Product'),
                  onTap: () {
                    Navigator.pop(context);
                    _assignProductToCell(context, cell);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.move_to_inbox),
                  title: const Text('Place Product from Conveyor'),
                  onTap: () {
                    Navigator.pop(context);
                    _placeFromConveyor(context, cell);
                  },
                ),
              ] else if (cell.status == 'OCCUPIED') ...[
                ListTile(
                  leading: const Icon(Icons.remove),
                  title: const Text('Remove Product'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProductFromCell(context, cell);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.move_to_inbox),
                  title: const Text('Move to Loading Zone'),
                  onTap: () {
                    Navigator.pop(context);
                    _moveToLoadingZone(context, cell);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Update Quantity'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateQuantity(context, cell);
                  },
                ),
              ],
              
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showCellDetails(context, cell);
                },
              ),
              
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _assignProductToCell(BuildContext context, WarehouseCell cell) {
    // TODO: Implement product assignment
  }

  void _placeFromConveyor(BuildContext context, WarehouseCell cell) {
    // TODO: Implement place from conveyor
  }

  void _removeProductFromCell(BuildContext context, WarehouseCell cell) {
    // TODO: Implement product removal
  }

  void _moveToLoadingZone(BuildContext context, WarehouseCell cell) {
    // TODO: Implement move to loading zone
  }

  void _updateQuantity(BuildContext context, WarehouseCell cell) {
    // TODO: Implement quantity update
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product to Cell'),
          content: const Text('Select a cell first, then use the action menu to assign a product.'),
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
}