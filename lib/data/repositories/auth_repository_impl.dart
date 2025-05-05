import 'package:ecommerce_app/data/datasources/api_client.dart';
import 'package:ecommerce_app/data/repositories/auth_repository.dart';
import 'package:ecommerce_app/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl(this.apiClient);

  @override
  Future<User> login(String username, String password) {
    return apiClient.login(username, password);
  }
}
