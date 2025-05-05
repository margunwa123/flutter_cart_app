abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class LoadProductByIdEvent extends ProductEvent {
  final int id;

  LoadProductByIdEvent(this.id);
}
