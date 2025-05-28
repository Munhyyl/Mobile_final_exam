import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import '../models/product_model.dart';

class OrderView extends StatelessWidget {
  final ProductModel product;

  const OrderView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: product.image != null && product.image!.isNotEmpty
              ? Image.network(
                  product.image!,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                )
              : const Icon(Icons.image_not_supported),
          title: Text(
            product.title ?? 'Unknown Product',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () {
                  provider.removeCount(product);
                },
              ),
              Text('${product.count}', style: const TextStyle(fontSize: 16.0)),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  provider.addCount(product);
                },
              ),
            ],
          ),
          trailing: Text(
            '\$${((product.price ?? 0.0) * product.count).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16.0, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
