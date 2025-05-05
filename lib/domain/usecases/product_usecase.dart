import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/domain/entities/product.dart';

class ProductUseCase {
  final ProductRepository repository;

  ProductUseCase(this.repository);

  Future<List<Product>> getProducts() {
    return repository.getProducts();
  }

  Future<Product> getProductById(int id) {
    return repository.getProductById(id);
  }
}
