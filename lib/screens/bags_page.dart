import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app_ex/widgeds/OrderView.dart';

class BagsPage extends StatefulWidget {
  const BagsPage({super.key});

  @override
  State<BagsPage> createState() => _BagsPageState();
}

class _BagsPageState extends State<BagsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final provider = Provider.of<GlobalProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      List<ProductModel> cartItems = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        cartItems.add(
          ProductModel(
            id: data['id'] ?? 0,
            title: data['title'] ?? 'Unknown Product',
            price: data['price']?.toDouble() ?? 0.0,
            image: data['image'] ?? '',
            count: data['count'] ?? 1,
          ),
        );
      }

      await provider.setCartItems(cartItems);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading cart: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        double total = provider.cartItems.fold(
          0,
          (sum, item) => sum + (item.price! * item.count),
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Миний сагс')),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.cartItems.isEmpty
              ? const Center(child: Text("Сагс хоосон байна."))
              : ListView.builder(
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    return OrderView(product: provider.cartItems[index]);
                  },
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Худалдаж авах логик
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Худалдан авалт амжилттай!'),
                      ),
                    );
                  },
                  child: const Text('Бүгдийг худалдаж авах'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
