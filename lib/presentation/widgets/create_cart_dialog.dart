import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_event.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCartDialog extends StatefulWidget {
  final Function(List<CartItem>) onCreateCart;

  const CreateCartDialog({Key? key, required this.onCreateCart})
    : super(key: key);

  @override
  State<CreateCartDialog> createState() => _CreateCartDialogState();
}

class _CreateCartDialogState extends State<CreateCartDialog> {
  final List<CartItem> _selectedItems = [];
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProductError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load products: ${state.message}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ProductBloc>().add(LoadProductsEvent());
                },
                child: const Text('Retry'),
              ),
            ],
          );
        } else if (state is ProductsLoaded) {
          final products = state.products;

          return AlertDialog(
            title: const Text('Create New Cart'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final selected = await _showProductSelectBottomSheet(context, products);

                      if (selected != null) {
                        setState(() {
                          _selectedProduct = selected;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedProduct?.title ?? 'Tap to select a product',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addToCart(products),
                    child: const Text('Add to Cart'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Selected Products',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        _selectedItems.isEmpty
                            ? const Center(child: Text('No products selected'))
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _selectedItems.length,
                              itemBuilder: (context, index) {
                                final item = _selectedItems[index];
                                final product = products.firstWhere(
                                  (p) => p.id == item.productId,
                                  orElse:
                                      () => Product(
                                        id: item.productId,
                                        title: 'Product #${item.productId}',
                                        price: 0,
                                        description: '',
                                        category: '',
                                        image: '',
                                        rating: Rating(rate: 0, count: 0),
                                      ),
                                );

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 16,
                                    ),
                                    title: Text(product.title),
                                    subtitle: Text(
                                      'Quantity: ${item.quantity}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showEditQuantityDialog(
                                              context,
                                              index,
                                              item,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedItems.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedItems.isEmpty
                        ? null
                        : () {
                          widget.onCreateCart(_selectedItems);
                        },
                child: const Text('Create Cart'),
              ),
            ],
          );
        }

        return const AlertDialog(
          content: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<Product?> _showProductSelectBottomSheet(BuildContext context, List<Product> products) {
    return showModalBottomSheet<Product>(
                      context: context,
                      builder: (context) {
                        return ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              title: Text(
                                product.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pop(context, product);
                              },
                            );
                          },
                        );
                      },
                    );
  }

  void _showEditQuantityDialog(BuildContext context, int index, CartItem item) {
    final TextEditingController editController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Quantity'),
            content: TextField(
              controller: editController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newQuantity = int.tryParse(editController.text);
                  if (newQuantity == null || newQuantity < 1) {
                    _showToast('Quantity must be at least 1');
                    return;
                  }

                  setState(() {
                    _selectedItems[index] = CartItem(
                      productId: item.productId,
                      quantity: newQuantity,
                    );
                  });

                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _addToCart(List<Product> products) {
    if (_selectedProduct == null) {
      _showToast('Please select a product');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 1) {
      _showToast('Quantity must be at least 1');
      return;
    }

    if (_selectedItems.any((item) => item.productId == _selectedProduct!.id)) {
      _showToast('This product is already in the cart');
      return;
    }

    setState(() {
      _selectedItems.add(
        CartItem(productId: _selectedProduct!.id, quantity: quantity),
      );
      _selectedProduct = null;
      _quantityController.text = '1';
    });
  }
}
