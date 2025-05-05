import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/usecases/product_usecase.dart';
import 'package:ecommerce_app/presentation/blocs/cart_item/cart_item_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/cart_item/cart_item_event.dart';
import 'package:ecommerce_app/presentation/blocs/cart_item/cart_item_state.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onViewDetails;
  
  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartItemBloc(
        context.read<ProductUseCase>(),
      )..add(LoadCartItemProductEvent(cartItem.productId)),
      child: _CartItemContent(
        cartItem: cartItem,
        onViewDetails: onViewDetails,
      ),
    );
  }
}

class _CartItemContent extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onViewDetails;
  
  const _CartItemContent({
    Key? key,
    required this.cartItem,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartItemBloc, CartItemState>(
      builder: (context, state) {
        if (state is CartItemLoaded) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  state.product.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
              title: Text(
                state.product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${state.product.price.toStringAsFixed(2)}'),
                  Text('Quantity: ${cartItem.quantity}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  onViewDetails(cartItem.productId);
                },
              ),
              isThreeLine: true,
            ),
          );
        } else if (state is CartItemLoading) {
          return const ListTile(
            title: Text('Loading product details...'),
            trailing: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is CartItemError) {
          return ListTile(
            title: Text('Error loading product #${state.productId}'),
            subtitle: Text('Quantity: ${cartItem.quantity}'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<CartItemBloc>().add(
                  LoadCartItemProductEvent(cartItem.productId)
                );
              },
            ),
          );
        }
        
        return ListTile(
          title: Text('Product ID: ${cartItem.productId}'),
          subtitle: Text('Quantity: ${cartItem.quantity}'),
          trailing: IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              onViewDetails(cartItem.productId);
            },
          ),
        );
      },
    );
  }
}