import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/theme/app_theme.dart';
import '../../widgets/shared/loading_indicator.dart';

class DeliveryListScreen extends ConsumerStatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  ConsumerState<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends ConsumerState<DeliveryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeliveries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement actual loading logic
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveries,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDeliveryDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryList('pending'),
          _buildDeliveryList('in_progress'),
          _buildDeliveryList('completed'),
        ],
      ),
    );
  }

  Widget _buildDeliveryList(String status) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    // Mock data for demonstration
    final deliveries = _getMockDeliveries(status);

    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status.replaceAll('_', ' ')} deliveries',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return _buildDeliveryCard(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(delivery['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(delivery['status']),
                    color: _getStatusColor(delivery['status']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery['trackingNumber'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        delivery['recipient'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  delivery['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  delivery['courier'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.home,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  delivery['address'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (delivery['notes'] != null) ...[
              const SizedBox(height: 8),
              Text(
                delivery['notes'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (delivery['status'] == 'pending')
                  TextButton(
                    onPressed: () => _updateDeliveryStatus(delivery['id'], 'in_progress'),
                    child: const Text('Accept'),
                  ),
                if (delivery['status'] == 'in_progress')
                  TextButton(
                    onPressed: () => _updateDeliveryStatus(delivery['id'], 'completed'),
                    child: const Text('Complete'),
                  ),
                TextButton(
                  onPressed: () => _showDeliveryDetails(delivery),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'in_progress':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<Map<String, dynamic>> _getMockDeliveries(String status) {
    // Mock data for demonstration
    final allDeliveries = {
      'pending': [
        {
          'id': '1',
          'trackingNumber': 'TRK001234',
          'recipient': 'John Smith',
          'address': 'Household A-101',
          'courier': 'FedEx',
          'time': '10:30 AM',
          'status': 'pending',
          'notes': 'Fragile package',
        },
        {
          'id': '2',
          'trackingNumber': 'TRK005678',
          'recipient': 'Sarah Johnson',
          'address': 'Household B-205',
          'courier': 'DHL',
          'time': '11:15 AM',
          'status': 'pending',
        },
      ],
      'in_progress': [
        {
          'id': '3',
          'trackingNumber': 'TRK009012',
          'recipient': 'Mike Wilson',
          'address': 'Household C-310',
          'courier': 'UPS',
          'time': '9:45 AM',
          'status': 'in_progress',
          'notes': 'Signature required',
        },
      ],
      'completed': [
        {
          'id': '4',
          'trackingNumber': 'TRK003456',
          'recipient': 'Emily Davis',
          'address': 'Household D-112',
          'courier': 'Amazon',
          'time': '8:30 AM',
          'status': 'completed',
        },
      ],
    };

    return allDeliveries[status] ?? [];
  }

  void _updateDeliveryStatus(String deliveryId, String newStatus) {
    // TODO: Implement actual status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery status updated to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
    _loadDeliveries();
  }

  void _showDeliveryDetails(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Details - ${delivery['trackingNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Recipient:', delivery['recipient']),
            _buildDetailRow('Address:', delivery['address']),
            _buildDetailRow('Courier:', delivery['courier']),
            _buildDetailRow('Time:', delivery['time']),
            _buildDetailRow('Status:', delivery['status']),
            if (delivery['notes'] != null)
              _buildDetailRow('Notes:', delivery['notes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddDeliveryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Delivery'),
        content: const Text('Delivery registration feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}