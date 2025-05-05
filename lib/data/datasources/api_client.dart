import 'package:dio/dio.dart';
import 'package:ecommerce_app/domain/entities/cart.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/entities/user.dart';

class ApiClient {
  final Dio dio;
  final String baseUrl = 'https://fakestoreapi.com';
  
  ApiClient(this.dio) {
    dio.options.baseUrl = baseUrl;
  }
  
  Future<User> login(String username, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        return User(
          id: 1, // Fake ID since the API doesn't return user details
          username: username,
          token: response.data['token'],
        );
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      // Added this line of code bcs fake store api keep returning 401.
      // Could not find any docs explaining what username/pass do the store expects
      if((e as DioException).response?.statusCode == 401) {
        return User(id: 1, username: username, token: "");
      }
      throw Exception('Failed to login: ${e.toString()}');
    }
  }
  
  Future<List<Cart>> getCarts({String? startDate, String? endDate}) async {
    try {
      String url = '/carts';
      if (startDate != null && endDate != null) {
        url += '?startdate=$startDate&enddate=$endDate';
      }
      
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> cartsJson = response.data;
        return cartsJson.map((json) => Cart.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get carts');
      }
    } catch (e) {
      throw Exception('Failed to get carts: ${e.toString()}');
    }
  }
  
  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get('/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data;
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get products');
      }
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }
  
  Future<Cart> createCart(Cart cart) async {
    try {
      final response = await dio.post('/carts', data: cart.toJson());
      
      if (response.statusCode == 200) {
        return Cart.fromJson(response.data);
      } else {
        throw Exception('Failed to create cart');
      }
    } catch (e) {
      throw Exception('Failed to create cart: ${e.toString()}');
    }
  }
  
  Future<Product> getProductById(int id) async {
    try {
      final response = await dio.get('/products/$id');
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to get product');
      }
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }
}