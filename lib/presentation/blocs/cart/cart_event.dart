import 'package:ecommerce_app/domain/entities/cart_item.dart';

abstract class CartEvent {}

class LoadCartsEvent extends CartEvent {
  final String? startDate;
  final String? endDate;

  LoadCartsEvent({this.startDate, this.endDate});
}

class CreateCartEvent extends CartEvent {
  final List<CartItem> products;

  CreateCartEvent({required this.products});
}

class ResetCartStateEvent extends CartEvent {}
