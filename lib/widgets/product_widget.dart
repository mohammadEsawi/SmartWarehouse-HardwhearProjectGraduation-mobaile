import 'package:flutter/material.dart';
import 'package:smart_warehouse_mobile/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showDetails;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Name
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: product.categoryColor.withOpacity(0.2),
                    radius: 20,
                    child: Icon(
                      product.categoryIcon,
                      size: 18,
                      color: product.categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.sku != null)
                          Text(
                            product.sku!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category Tag
              if (product.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category!,
                    style: TextStyle(
                      fontSize: 10,
                      color: product.categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Stats Row
              if (showDetails) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      Icons.grid_view,
                      '${product.occupiedCells}',
                      'Cells',
                    ),
                    _buildStatItem(
                      Icons.numbers,
                      '${product.totalQuantity}',
                      'Total',
                    ),
                    if (product.rfidUid != null)
                      const Icon(
                        Icons.qr_code,
                        size: 16,
                        color: Colors.purple,
                      ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.grid_view,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.occupiedCells} cells',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showTrailing;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: product.categoryColor.withOpacity(0.2),
        child: Icon(
          product.categoryIcon,
          color: product.categoryColor,
        ),
      ),
      title: Text(product.displayName),
      subtitle: product.category != null
          ? Text(product.category!)
          : null,
      trailing: showTrailing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.occupiedCells > 0)
                  Chip(
                    label: Text('${product.occupiedCells}'),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            )
          : null,
      onTap: onTap,
    );
  }
}