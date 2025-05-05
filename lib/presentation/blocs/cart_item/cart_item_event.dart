abstract class CartItemEvent {}

class LoadCartItemProductEvent extends CartItemEvent {
  final int productId;
  
  LoadCartItemProductEvent(this.productId);
}

class ResetCartItemEvent extends CartItemEvent {}