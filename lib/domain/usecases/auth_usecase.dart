import 'package:ecommerce_app/data/repositories/auth_repository.dart';
import 'package:ecommerce_app/domain/entities/user.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  Future<User> login(String username, String password) {
    if (username.length < 8 || password.length < 8) {
      throw Exception('Username and password must be at least 8 characters');
    }
    return repository.login(username, password);
  }
}
