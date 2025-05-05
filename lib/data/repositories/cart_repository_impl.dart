import 'package:ecommerce_app/data/datasources/api_client.dart';
import 'package:ecommerce_app/data/repositories/cart_repository.dart';
import 'package:ecommerce_app/domain/entities/cart.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiClient apiClient;

  CartRepositoryImpl(this.apiClient);

  @override
  Future<List<Cart>> getCarts({String? startDate, String? endDate}) {
    return apiClient.getCarts(startDate: startDate, endDate: endDate);
  }

  @override
  Future<Cart> createCart(Cart cart) {
    return apiClient.createCart(cart);
  }
}
