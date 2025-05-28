import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shop_app_ex/models/product_model.dart';
import 'package:shop_app_ex/models/user_model.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/services/httpservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRepository {
  final HttpService httpService;

  MyRepository({required this.httpService});

  Future<List<ProductModel>?> fetchProductData() async {
    try {
      final jsonData = await httpService.getData('products', null);
      return ProductModel.fromList(jsonData);
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<UserModel?> fetchUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/users/$id'),
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Future<void> fetchCartProductsAndSetToProvider(
    BuildContext context,
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/carts/user/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final cartData = data.last;
          final List<dynamic> productsData = cartData['products'];
          List<ProductModel> cartProducts = [];

          for (var product in productsData) {
            final prodResponse = await http.get(
              Uri.parse(
                'https://fakestoreapi.com/products/${product['productId']}',
              ),
            );
            if (prodResponse.statusCode == 200) {
              final prodData = jsonDecode(prodResponse.body);
              final productModel = ProductModel.fromJson(prodData);
              productModel.count = product['quantity'];
              cartProducts.add(productModel);

              // Firebase-д хадгалах
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('carts')
                    .doc(user.uid)
                    .collection('items')
                    .doc(productModel.id.toString())
                    .set({
                      'id': productModel.id,
                      'title': productModel.title,
                      'price': productModel.price,
                      'count': productModel.count,
                      'image': productModel.image,
                    });
              }
            }
          }

          Provider.of<GlobalProvider>(
            context,
            listen: false,
          ).setCartItems(cartProducts);
        }
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }
}
