import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/widgeds/ProductView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app_ex/models/product_model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final provider = Provider.of<GlobalProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .get();

    List<ProductModel> favoriteItems = [];
    for (var doc in snapshot.docs) {
      favoriteItems.add(
        ProductModel(
          id: doc.data()['id'],
          title: doc.data()['title'],
          price: doc.data()['price'],
          image: doc.data()['image'],
          isFavorite: true,
        ),
      );
    }

    provider.favoriteItems = favoriteItems;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Миний дуртай')),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.favoriteItems.isEmpty
              ? const Center(child: Text("Дуртай бүтээгдэхүүн байхгүй."))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          children: List.generate(
                            provider.favoriteItems.length,
                            (index) =>
                                ProductViewShop(provider.favoriteItems[index]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
