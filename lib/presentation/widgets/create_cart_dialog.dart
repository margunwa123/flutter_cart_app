import 'package:flutter/material.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/entities/product.dart';

class CreateCartDialog extends StatefulWidget {
  final List<Product> products;
  final Function(List<CartItem>) onCreateCart;
  
  const CreateCartDialog({
    Key? key,
    required this.products,
    required this.onCreateCart,
  }) : super(key: key);

  @override
  State<CreateCartDialog> createState() => _CreateCartDialogState();
}

class _CreateCartDialogState extends State<CreateCartDialog> {
  final List<CartItem> _selectedItems = [];
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController(text: '1');
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Cart'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Product>(
              decoration: const InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(),
              ),
              value: _selectedProduct,
              items: widget.products.map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Text(
                    product.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  _selectedProduct = product;
                });
              },
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
              onPressed: _addToCart,
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
              child: _selectedItems.isEmpty
                  ? const Center(child: Text('No products selected'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = _selectedItems[index];
                        final product = widget.products.firstWhere(
                          (p) => p.id == item.productId,
                        );
                        
                        return ListTile(
                          title: Text(product.title),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _selectedItems.removeAt(index);
                              });
                            },
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
          onPressed: _selectedItems.isEmpty
              ? null
              : () {
                  widget.onCreateCart(_selectedItems);
                },
          child: const Text('Create Cart'),
        ),
      ],
    );
  }
  
  void _addToCart() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }
    
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be at least 1')),
      );
      return;
    }
    
    // Check for duplicates
    if (_selectedItems.any((item) => item.productId == _selectedProduct!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is already in the cart')),
      );
      return;
    }
    
    setState(() {
      _selectedItems.add(
        CartItem(
          productId: _selectedProduct!.id,
          quantity: quantity,
        ),
      );
      _selectedProduct = null;
      _quantityController.text = '1';
    });
  }
}