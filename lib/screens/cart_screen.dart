import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(item.quantity.toString())),
                      title: Text(item.product.name),
                      subtitle: Text('x${item.quantity}  •  \₹${item.product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => cart.removeOne(item.product),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            onPressed: () => cart.add(item.product),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          IconButton(
                            onPressed: () => cart.remove(item.product),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Total: \₹${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                          final user = context.read<AuthProvider>().currentUser;
                          if (user == null) return;
                          await context.read<OrdersProvider>().placeOrder(userId: user.uid, items: items);
                          if (context.mounted) {
                            context.read<CartProvider>().clear();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed!')));
                          }
                        },
                  child: const Text('Checkout'),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

