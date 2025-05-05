import 'package:ecommerce_app/domain/entities/cart.dart';

abstract class CartRepository {
  Future<List<Cart>> getCarts({String? startDate, String? endDate});
  Future<Cart> createCart(Cart cart);
}
