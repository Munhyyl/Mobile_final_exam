import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/models/product_model.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel product;

  const ProductDetail(this.product, {super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final _commentController = TextEditingController();

  Future<void> addComment(String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сэтгэгдэл оруулна уу')));
      return;
    }

    try {
      final provider = Provider.of<GlobalProvider>(context, listen: false);
      final userName =
          provider.currentUser?.name?.firstname ??
          user.displayName ??
          user.email!.split('@')[0];

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id.toString())
          .collection('comments')
          .add({
            'text': comment.trim(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'name': userName,
            'userId': user.uid,
          });
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сэтгэгдэл амжилттай нэмэгдлээ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сэтгэгдэл нэмэхэд алдаа гарлаа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.title ?? 'Product')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.image!,
              height: 200,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title!,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PRICE: \$${widget.product.price?.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Сэтгэгдэл бичнэ үү',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => addComment(_commentController.text),
                    child: const Text('Сэтгэгдэл илгээх'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Сэтгэгдэл',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(widget.product.id.toString())
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            title: Text(comment['name']),
                            subtitle: Text(comment['text']),
                            trailing: Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                comment['timestamp'],
                              ).toString().substring(0, 16),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (provider.currentUser == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else {
            provider.addCartItems(widget.product);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Added to cart')));
          }
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
