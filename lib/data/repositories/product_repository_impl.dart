import 'package:ecommerce_app/data/datasources/api_client.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/domain/entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;

  ProductRepositoryImpl(this.apiClient);

  @override
  Future<List<Product>> getProducts() {
    return apiClient.getProducts();
  }

  @override
  Future<Product> getProductById(int id) {
    return apiClient.getProductById(id);
  }
}
