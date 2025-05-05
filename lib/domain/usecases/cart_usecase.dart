import 'package:ecommerce_app/data/repositories/cart_repository.dart';
import 'package:ecommerce_app/domain/entities/cart.dart';

class CartUseCase {
  final CartRepository repository;

  CartUseCase(this.repository);

  Future<List<Cart>> getCarts({String? startDate, String? endDate}) {
    return repository.getCarts(startDate: startDate, endDate: endDate);
  }

  Future<Cart> createCart(Cart cart) {
    // Validate cart items
    for (var item in cart.products) {
      if (item.quantity < 1) {
        throw Exception('Quantity cannot be less than 1');
      }
    }

    // Check for duplicates
    final productIds = cart.products.map((item) => item.productId).toList();
    final uniqueProductIds = productIds.toSet().toList();
    if (productIds.length != uniqueProductIds.length) {
      throw Exception('Cannot add duplicate items to cart');
    }

    return repository.createCart(cart);
  }
}
