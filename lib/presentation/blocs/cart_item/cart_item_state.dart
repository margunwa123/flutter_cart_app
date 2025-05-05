import 'package:ecommerce_app/domain/entities/product.dart';

abstract class CartItemState {}

class CartItemInitial extends CartItemState {}

class CartItemLoading extends CartItemState {
  final int productId;

  CartItemLoading(this.productId);
}

class CartItemLoaded extends CartItemState {
  final Product product;
  final int quantity;

  CartItemLoaded({required this.product, required this.quantity});
}

class CartItemError extends CartItemState {
  final String message;
  final int productId;

  CartItemError({required this.message, required this.productId});
}
