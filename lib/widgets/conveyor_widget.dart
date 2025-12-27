import 'package:flutter/material.dart';

class ConveyorWidget extends StatelessWidget {
  final bool hasProduct;
  final String? productName;
  final String? rfidTag;
  final bool ldr1Active;
  final bool ldr2Active;
  final String conveyorState;
  final VoidCallback? onTap;

  const ConveyorWidget({
    super.key,
    required this.hasProduct,
    this.productName,
    this.rfidTag,
    required this.ldr1Active,
    required this.ldr2Active,
    this.conveyorState = 'IDLE',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conveyor System',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Conveyor Visualization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LDR1 Sensor
                  _buildSensorIndicator(
                    'LDR1',
                    'Entry',
                    ldr1Active,
                  ),
                  
                  // Conveyor Belt
                  Expanded(
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: _getConveyorColors(),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated moving effect
                          if (conveyorState != 'IDLE' && conveyorState != 'STOPPED')
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          // Product on conveyor
                          if (hasProduct)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  productName?.substring(0, 1).toUpperCase() ?? 'P',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Conveyor lines
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ConveyorLinesPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // LDR2 Sensor
                  _buildSensorIndicator(
                    'LDR2',
                    'Exit',
                    ldr2Active,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Status Information
              Row(
                children: [
                  // Product Status
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasProduct
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasProduct ? Icons.inventory : Icons.inventory_2,
                            color: hasProduct ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasProduct ? 'Product Detected' : 'No Product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: hasProduct ? Colors.green : Colors.grey,
                                  ),
                                ),
                                if (hasProduct && productName != null)
                                  Text(
                                    productName!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // RFID Status
                  if (rfidTag != null && rfidTag!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.qr_code,
                                size: 16,
                                color: Colors.purple,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'RFID',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rfidTag!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Conveyor State
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStateColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Conveyor State:',
                      style: TextStyle(fontSize: 12),
                    ),
                    Chip(
                      label: Text(
                        conveyorState,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStateColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: _getStateColor().withOpacity(0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorIndicator(String label, String description, bool isActive) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          description,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  List<Color> _getConveyorColors() {
    if (hasProduct) {
      return [
        Colors.green.shade300,
        Colors.green.shade500,
        Colors.green.shade300,
      ];
    } else if (conveyorState == 'MOVING') {
      return [
        Colors.orange.shade300,
        Colors.orange.shade500,
        Colors.orange.shade300,
      ];
    } else {
      return [
        Colors.grey.shade300,
        Colors.grey.shade500,
        Colors.grey.shade300,
      ];
    }
  }

  Color _getStateColor() {
    switch (conveyorState) {
      case 'IDLE':
        return Colors.grey;
      case 'MOVING':
        return Colors.orange;
      case 'WAIT_RFID':
        return Colors.blue;
      case 'STOPPED':
        return Colors.red;
      case 'ERROR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ConveyorLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const lineSpacing = 20.0;
    final lineCount = (size.width / lineSpacing).ceil();

    for (int i = 0; i < lineCount; i++) {
      final x = i * lineSpacing;
      final start = Offset(x, 0);
      final end = Offset(x, size.height);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}