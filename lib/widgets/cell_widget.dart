import 'package:flutter/material.dart';
import 'package:smart_warehouse_mobile/models/cell.dart';

class CellWidget extends StatelessWidget {
  final WarehouseCell cell;
  final VoidCallback onTap;
  final bool showDetails;
  final bool compactMode;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    this.showDetails = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compactMode) {
      return _buildCompactCell(context);
    }
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _getCellColor(context),
          border: Border.all(
            color: cell.isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cell.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      _getStatusIcon(),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cell.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cell.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cell.statusColor,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Product Details
                  if (cell.status == 'OCCUPIED' && showDetails) ...[
                    Text(
                      cell.productName ?? 'Product',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (cell.productSku != null)
                      Text(
                        'SKU: ${cell.productSku}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${cell.quantity}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ] else if (showDetails) ...[
                    const Center(
                      child: Icon(
                        Icons.crop_square,
                        size: 32,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                  
                  // Last Updated
                  if (showDetails) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Updated: ${cell.formattedUpdatedAt}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Loading Overlay
            if (cell.isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCell(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _getCellColor(context),
          border: Border.all(
            color: cell.isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cell.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                _getCompactStatusIcon(),
                size: 12,
                color: cell.statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCellColor(BuildContext context) {
    switch (cell.status) {
      case 'OCCUPIED':
        return Colors.green.withOpacity(0.3);
      case 'RESERVED':
        return Colors.orange.withOpacity(0.3);
      default:
        return Theme.of(context).colorScheme.surface.withOpacity(0.5);
    }
  }

  Widget _getStatusIcon() {
    return Icon(
      cell.statusIcon,
      size: 16,
      color: cell.statusColor,
    );
  }

  IconData _getCompactStatusIcon() {
    switch (cell.status) {
      case 'OCCUPIED':
        return Icons.check;
      case 'RESERVED':
        return Icons.access_time;
      default:
        return Icons.crop_square;
    }
  }
}