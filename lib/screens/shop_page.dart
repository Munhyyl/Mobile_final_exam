import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/models/product_model.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/repository/repository.dart';
import 'package:shop_app_ex/widgeds/ProductView.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late Future<List<ProductModel>?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _getProductData();
  }

  Future<List<ProductModel>?> _getProductData() async {
    final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    if (globalProvider.products.isNotEmpty) {
      return globalProvider.products;
    }

    List<ProductModel>? data = await Provider.of<MyRepository>(
      context,
      listen: false,
    ).fetchProductData();

    if (data != null) {
      globalProvider.setProducts(data);
      return data;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final viewToggle = Provider.of<GlobalProvider>(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Бүтээгдэхүүнүүд',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    viewToggle.toggleView();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: viewToggle.isGridView
                  ? GridView.builder(
                      itemCount: snapshot.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        return ProductViewShop(snapshot.data![index]);
                      },
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: List.generate(
                          snapshot.data!.length,
                          (index) => ProductViewShop(snapshot.data![index]),
                        ),
                      ),
                    ),
            ),
          );
        } else {
          return const Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
