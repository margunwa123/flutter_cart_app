import 'package:ecommerce_app/domain/usecases/product_usecase.dart';
import 'package:ecommerce_app/presentation/blocs/cart_item/cart_item_event.dart';
import 'package:ecommerce_app/presentation/blocs/cart_item/cart_item_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemBloc extends Bloc<CartItemEvent, CartItemState> {
  final ProductUseCase productUseCase;

  CartItemBloc(this.productUseCase) : super(CartItemInitial()) {
    on<LoadCartItemProductEvent>(_onLoadCartItemProduct);
    on<ResetCartItemEvent>(_onResetCartItem);
  }

  Future<void> _onLoadCartItemProduct(
    LoadCartItemProductEvent event,
    Emitter<CartItemState> emit,
  ) async {
    emit(CartItemLoading(event.productId));

    try {
      final product = await productUseCase.getProductById(event.productId);
      emit(
        CartItemLoaded(product: product, quantity: 0),
      ); // Default quantity, will be updated by widget
    } catch (e) {
      emit(CartItemError(message: e.toString(), productId: event.productId));
    }
  }

  void _onResetCartItem(ResetCartItemEvent event, Emitter<CartItemState> emit) {
    emit(CartItemInitial());
  }
}
