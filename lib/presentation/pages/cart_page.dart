import 'package:ecommerce_app/domain/entities/cart.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_event.dart';
import 'package:ecommerce_app/presentation/blocs/auth/auth_state.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_event.dart';
import 'package:ecommerce_app/presentation/blocs/cart/cart_state.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_bloc.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_event.dart';
import 'package:ecommerce_app/presentation/blocs/product/product_state.dart';
import 'package:ecommerce_app/presentation/widgets/create_cart_dialog.dart';
import 'package:ecommerce_app/presentation/widgets/product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? startDate;
  DateTime? endDate;
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCartsEvent());
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Logout successful')));
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart created successfully')),
              );
              context.read<CartBloc>().add(LoadCartsEvent());
            } else if (state is CartError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is CartLoading && state is! CartsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Cart> carts = [];
            if (state is CartsLoaded) {
              carts = state.carts;
            }

            final int totalPages = (carts.length / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex =
                startIndex + _itemsPerPage > carts.length
                    ? carts.length
                    : startIndex + _itemsPerPage;

            final List<Cart> paginatedCarts =
                carts.isEmpty ? [] : carts.sublist(startIndex, endIndex);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilter(),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        carts.isEmpty
                            ? const Center(child: Text('No carts found'))
                            : _buildCartTable(paginatedCarts),
                  ),
                  if (carts.isNotEmpty) _buildPagination(totalPages),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateCartDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Converts a date string (in ISO format: YYYY-MM-DD) to DD-MM-YYYY format.
  String? _formatDateToReadable(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return null;
    }
  }

  Widget _buildDateFilter() {
    return Column(
      children: [
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: startDate != null ? dateFormat.format(startDate!) : '',
          ),
          decoration: const InputDecoration(
            labelText: 'Start Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                startDate = date;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: endDate != null ? dateFormat.format(endDate!) : '',
          ),
          decoration: const InputDecoration(
            labelText: 'End Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                endDate = date;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (startDate != null && endDate != null) {
                  context.read<CartBloc>().add(
                    LoadCartsEvent(
                      startDate: dateFormat.format(startDate!),
                      endDate: dateFormat.format(endDate!),
                    ),
                  );
                }
              },
              child: const Text('Filter'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
                context.read<CartBloc>().add(LoadCartsEvent());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartTable(List<Cart> carts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Products')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            carts.map((cart) {
              return DataRow(
                cells: [
                  DataCell(Text('${cart.id}')),
                  DataCell(Text('${cart.products.length} items')),
                  DataCell(Text(_formatDateToReadable(cart.date) ?? "-")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        _showCartDetails(context, cart);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentPage > 0
                  ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                  : null,
        ),
        Text('${_currentPage + 1} / $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed:
              _currentPage < totalPages - 1
                  ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                  : null,
        ),
      ],
    );
  }

  void _showCartDetails(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cart #${cart.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cart.products.length,
              itemBuilder: (context, index) {
                final product = cart.products[index];
                return ListTile(
                  title: Text('Product ID: ${product.productId}'),
                  subtitle: Text('Quantity: ${product.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      Navigator.pop(context);
                      _showProductDetails(context, product.productId);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, int productId) {
    context.read<ProductBloc>().add(LoadProductByIdEvent(productId));

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (state is ProductLoaded) {
              return ProductDialog(product: state.product);
            } else if (state is ProductError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }
            return const AlertDialog(
              content: Text('Loading product details...'),
            );
          },
        );
      },
    );
  }

  void _showCreateCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductsLoaded) {
              return CreateCartDialog(
                products: state.products,
                onCreateCart: (List<CartItem> items) {
                  context.read<CartBloc>().add(
                    CreateCartEvent(products: items),
                  );
                  Navigator.pop(context);
                },
              );
            }
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
