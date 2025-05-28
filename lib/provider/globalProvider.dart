import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop_app_ex/models/product_model.dart';
import 'package:shop_app_ex/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalProvider extends ChangeNotifier {
  List<ProductModel> products = [];
  List<UserModel> users = [];
  List<ProductModel> cartItems = [];
  List<ProductModel> favoriteItems = [];
  int currentIdx = 0;
  UserModel? _currentUser;
  bool _isGridView = false;

  UserModel? get currentUser => _currentUser;
  bool get isGridView => _isGridView;
  GlobalProvider() {
    init();
  }

  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        setCurrentUser(null);
        cartItems = [];
        favoriteItems = [];
      }
      notifyListeners();
    });
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void changeCurrentIdx(int idx) {
    currentIdx = idx;
    notifyListeners();
  }

  void setProducts(List<ProductModel> data) {
    products = data;
    notifyListeners();
  }

  void setUsers(List<UserModel> data) {
    users = data;
    notifyListeners();
  }

  Future<void> addCartItems(ProductModel item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (cartItems.any((cartItem) => cartItem.id == item.id)) {
        final index = cartItems.indexWhere(
          (cartItem) => cartItem.id == item.id,
        );
        cartItems[index].count++;
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(item.id.toString())
            .update({'count': cartItems[index].count});
      } else {
        item.count = 1;
        cartItems.add(item);
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(item.id.toString())
            .set({
              'id': item.id,
              'title': item.title,
              'price': item.price,
              'count': item.count,
              'image': item.image,
            });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> setCartItems(List<ProductModel> items) async {
    cartItems = items;
    notifyListeners();
  }

  Future<void> addCount(ProductModel item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (cartItems.any((cartItem) => cartItem.id == item.id)) {
        final index = cartItems.indexWhere(
          (cartItem) => cartItem.id == item.id,
        );
        cartItems[index].count++;
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(user.uid)
            .collection('items')
            .doc(item.id.toString())
            .update({'count': cartItems[index].count});
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error increasing count: $e');
    }
  }

  Future<void> removeCount(ProductModel item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (cartItems.any((cartItem) => cartItem.id == item.id)) {
        final index = cartItems.indexWhere(
          (cartItem) => cartItem.id == item.id,
        );
        if (cartItems[index].count > 1) {
          cartItems[index].count--;
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(user.uid)
              .collection('items')
              .doc(item.id.toString())
              .update({'count': cartItems[index].count});
        } else {
          cartItems.removeAt(index);
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(user.uid)
              .collection('items')
              .doc(item.id.toString())
              .delete();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing count: $e');
    }
  }

  Future<void> toggleFavorite(ProductModel item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      item.isFavorite = !item.isFavorite;

      // products жагсаалтын харгалзах бүтээгдэхүүний төлөвийг шинэчлэх
      final productIndex = products.indexWhere((p) => p.id == item.id);
      if (productIndex != -1) {
        products[productIndex].isFavorite = item.isFavorite;
      }

      if (item.isFavorite) {
        favoriteItems.add(item);
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .collection('items')
            .doc(item.id.toString())
            .set({
              'id': item.id,
              'title': item.title,
              'price': item.price,
              'image': item.image,
            });
      } else {
        favoriteItems.removeWhere((favItem) => favItem.id == item.id);
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .collection('items')
            .doc(item.id.toString())
            .delete();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    try {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final storage = FlutterSecureStorage();
      return await storage.read(key: 'token');
    } catch (e) {
      debugPrint('Error retrieving token: $e');
      return null;
    }
  }
}
