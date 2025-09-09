import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final o = orders[index];
        return ListTile(
          title: Text('Order #${o.id.substring(0, 6)}'),
          subtitle: Text('${o.items.length} items • ${o.createdAt}'),
          trailing: Text('\$${o.total.toStringAsFixed(2)}'),
        );
      },
    );
  }
}

