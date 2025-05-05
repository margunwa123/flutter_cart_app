import 'package:ecommerce_app/domain/entities/cart.dart';
import 'package:ecommerce_app/domain/usecases/cart_usecase.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_event.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartUseCase cartUseCase;

  CartBloc(this.cartUseCase) : super(CartInitial()) {
    on<LoadCartsEvent>(_onLoadCarts);
    on<CreateCartEvent>(_onCreateCart);
    on<ResetCartStateEvent>(_onResetCartState);
  }

  Future<void> _onLoadCarts(
    LoadCartsEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final carts = await cartUseCase.getCarts(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(CartsLoaded(carts));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCreateCart(
    CreateCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = Cart(
        userId: 1, // Hardcoded for demo
        date: DateTime.now().toIso8601String(),
        products: event.products,
      );

      final createdCart = await cartUseCase.createCart(cart);
      emit(CartCreated(createdCart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void _onResetCartState(ResetCartStateEvent event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}
