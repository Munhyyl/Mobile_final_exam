import 'package:json_annotation/json_annotation.dart';
import '../models/product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable(createToJson: false)
class CartModel {
  int id;
  int userId;
  DateTime date;
  List<ProductModel> products;

  CartModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  static List<CartModel> fromList(List<dynamic> data) =>
      data.map((e) => CartModel.fromJson(e as Map<String, dynamic>)).toList();
}
