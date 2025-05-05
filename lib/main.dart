import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/data/datasources/api_client.dart';
import 'package:ecommerce_app/domain/usecases/auth_usecase.dart';
import 'package:ecommerce_app/domain/usecases/cart_usecase.dart';
import 'package:ecommerce_app/domain/usecases/product_usecase.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_bloc.dart';
import 'package:ecommerce_app/presentation/pages/login_page.dart';
import 'package:ecommerce_app/presentation/pages/cart_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Dio dio = Dio();
  
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(dio);
    
    final authRepository = AuthRepositoryImpl(apiClient);
    final cartRepository = CartRepositoryImpl(apiClient);
    final productRepository = ProductRepositoryImpl(apiClient);
    
    final authUseCase = AuthUseCase(authRepository);
    final cartUseCase = CartUseCase(cartRepository);
    final productUseCase = ProductUseCase(productRepository);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authUseCase),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(cartUseCase),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(productUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}