import 'package:ecommerce_app/domain/entities/cart.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartsLoaded extends CartState {
  final List<Cart> carts;

  CartsLoaded(this.carts);
}

class CartCreated extends CartState {
  final Cart cart;

  CartCreated(this.cart);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}
