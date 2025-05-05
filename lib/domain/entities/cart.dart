import 'package:ecommerce_app/domain/entities/cart_item.dart';

class Cart {
  final int? id;
  final int userId;
  final String date;
  final List<CartItem> products;

  Cart({
    this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['userId'],
      date: json['date'],
      products:
          (json['products'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date,
      'products': products.map((item) => item.toJson()).toList(),
    };
  }
}
