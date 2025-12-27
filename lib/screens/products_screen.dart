import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_warehouse_mobile/providers/warehouse_provider.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  bool _sortAscending = true;
  String _sortField = 'name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarehouseProvider>(context);
    List<Product> filteredProducts = _filterProducts(provider.products);

    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search products...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: [
                          'ALL',
                          ...AppConstants.productCategories,
                        ].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      tooltip: _sortAscending ? 'Ascending' : 'Descending',
                    ),
                    IconButton(
                      onPressed: () {
                        _showSortOptions(context);
                      },
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort Options',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.refreshData();
              },
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Add your first product',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            _showProductDetails(context, product);
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

  List<Product> _filterProducts(List<Product> products) {
    List<Product> filtered = List.from(products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product.name.toLowerCase();
        final sku = product.sku?.toLowerCase() ?? '';
        final search = _searchQuery.toLowerCase();
        return name.contains(search) || sku.contains(search);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'ALL') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Apply sorting
    filtered = _sortProducts(filtered);

    return filtered;
  }

  List<Product> _sortProducts(List<Product> products) {
    products.sort((a, b) {
      int comparison = 0;
      
      switch (_sortField) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'sku':
          comparison = (a.sku ?? '').compareTo(b.sku ?? '');
          break;
        case 'category':
          comparison = (a.category ?? '').compareTo(b.category ?? '');
          break;
        case 'quantity':
          comparison = a.totalQuantity.compareTo(b.totalQuantity);
          break;
        case 'cells':
          comparison = a.occupiedCells.compareTo(b.occupiedCells);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    return products;
  }

  void _showSortOptions(BuildContext context) {
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
              const Text(
                'Sort Products By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('Name'),
                trailing: _sortField == 'name'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _sortField = 'name';
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('SKU'),
                trailing: _sortField == 'sku'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _sortField = 'sku';
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Category'),
                trailing: _sortField == 'category'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _sortField = 'category';
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.numbers),
                title: const Text('Total Quantity'),
                trailing: _sortField == 'quantity'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _sortField = 'quantity';
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Occupied Cells'),
                trailing: _sortField == 'cells'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _sortField = 'cells';
                  });
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
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
                children: [
                  CircleAvatar(
                    backgroundColor: product.categoryColor.withOpacity(0.2),
                    child: Icon(
                      product.categoryIcon,
                      color: product.categoryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.sku != null)
                          Text(
                            'SKU: ${product.sku}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (product.category != null)
                    Chip(
                      label: Text(product.category!),
                      backgroundColor: product.categoryColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: product.categoryColor),
                    ),
                  Chip(
                    label: Text('${product.occupiedCells} cells'),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
                  Chip(
                    label: Text('${product.totalQuantity} total'),
                    backgroundColor: Colors.green.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
                  if (product.rfidUid != null)
                    Chip(
                      label: const Text('RFID'),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.purple),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Product Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('RFID UID'),
                subtitle: Text(product.rfidUid ?? 'Not assigned'),
                trailing: IconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: () {
                    if (product.rfidUid != null) {
                      // TODO: Copy to clipboard
                    }
                  },
                ),
              ),
              
              if (product.weightGrams != null)
                ListTile(
                  leading: const Icon(Icons.scale),
                  title: const Text('Weight'),
                  subtitle: Text('${product.weightGrams} grams'),
                ),
              
              ListTile(
                leading: const Icon(Icons.auto_mode),
                title: const Text('Auto Assign'),
                subtitle: Text(product.autoAssign ? 'Enabled' : 'Disabled'),
                trailing: Switch(
                  value: product.autoAssign,
                  onChanged: (value) {
                    // TODO: Update auto assign
                  },
                ),
              ),
              
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
                        _showProductActions(context, product);
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

  void _showProductActions(BuildContext context, Product product) {
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
                'Actions for ${product.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(context);
                  _editProduct(context, product);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Assign to Cell'),
                onTap: () {
                  Navigator.pop(context);
                  _assignProductToCell(context, product);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Update RFID'),
                onTap: () {
                  Navigator.pop(context);
                  _updateRFID(context, product);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Product'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteProduct(context, product);
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

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Product management feature coming soon!'),
              ],
            ),
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

  void _editProduct(BuildContext context, Product product) {
    // TODO: Implement edit product
  }

  void _assignProductToCell(BuildContext context, Product product) {
    // TODO: Implement assign to cell
  }

  void _updateRFID(BuildContext context, Product product) {
    // TODO: Implement update RFID
  }

  void _deleteProduct(BuildContext context, Product product) {
    // TODO: Implement delete product
  }
}