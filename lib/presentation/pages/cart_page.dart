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
import 'package:ecommerce_app/presentation/widgets/cart_item_widget.dart';
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
  // Since the cart API doesn't actually support pagination, we'll simulate pagination
  // by fetching all carts, then managing it in this individual component
  int _itemsPerPage = 5;
  final List<int> _availablePageSizes = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCartsEvent());
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
              setState(() {
                _currentPage = 0;
              });
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
                            : _buildCartTable(carts),
                  ),
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
                  setState(() {
                    _currentPage = 0;
                  });
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
                  _currentPage = 0;
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
    final int totalPages = (carts.length / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex =
        startIndex + _itemsPerPage > carts.length
            ? carts.length
            : startIndex + _itemsPerPage;

    final List<Cart> paginatedCarts =
        carts.isEmpty ? [] : carts.sublist(startIndex, endIndex);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: const [
                DataColumn(
                  label: Text(
                    'ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Products',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows:
                  paginatedCarts.map((cart) {
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
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Items per page: '),
            DropdownButton<int>(
              value: _itemsPerPage,
              items:
                  _availablePageSizes.map((pageSize) {
                    return DropdownMenuItem<int>(
                      value: pageSize,
                      child: Text('$pageSize'),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _itemsPerPage = value;
                    _currentPage = 0;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (carts.isNotEmpty)
          Column(
            children: [
              _buildPaginationInfo(paginatedCarts.length, carts.length),
              _buildPagination(totalPages),
            ],
          ),
      ],
    );
  }

  Widget _buildPaginationInfo(int entries, int totalItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Showing $entries of total $totalItems entries',
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    List<int> pageNumbers = [];

    pageNumbers.add(0);

    if (_currentPage > 1) {
      pageNumbers.add(_currentPage - 1);
    }

    if (_currentPage > 0) {
      pageNumbers.add(_currentPage);
    }

    if (_currentPage < totalPages - 1) {
      pageNumbers.add(_currentPage + 1);
    }

    if (totalPages > 1) {
      pageNumbers.add(totalPages - 1);
    }

    pageNumbers = pageNumbers.toSet().toList();
    pageNumbers.sort();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed:
                  _currentPage > 0
                      ? () {
                        setState(() {
                          _currentPage = 0;
                        });
                      }
                      : null,
              tooltip: 'First Page',
            ),
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
              tooltip: 'Previous Page',
            ),
            ...pageNumbers.map((pageIndex) {
              if (pageIndex > 0 &&
                  pageNumbers.contains(pageIndex - 1) &&
                  pageIndex - 1 !=
                      pageNumbers[pageNumbers.indexOf(pageIndex) - 1]) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('...'),
                    ),
                    _buildPageButton(pageIndex, totalPages),
                  ],
                );
              } else if (pageIndex < totalPages - 1 &&
                  pageNumbers.contains(pageIndex + 1) &&
                  pageIndex + 1 !=
                      pageNumbers[pageNumbers.indexOf(pageIndex) + 1]) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageButton(pageIndex, totalPages),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('...'),
                    ),
                  ],
                );
              }
              return _buildPageButton(pageIndex, totalPages);
            }).toList(),
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
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed:
                  _currentPage < totalPages - 1
                      ? () {
                        setState(() {
                          _currentPage = totalPages - 1;
                        });
                      }
                      : null,
              tooltip: 'Last Page',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton(int pageIndex, int totalPages) {
    final isCurrentPage = pageIndex == _currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCurrentPage
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
          foregroundColor: isCurrentPage ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 40),
        ),
        onPressed:
            isCurrentPage
                ? null
                : () {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
        child: Text('${pageIndex + 1}'),
      ),
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
                final cartItem = cart.products[index];
                return CartItemWidget(
                  cartItem: cartItem,
                  onViewDetails: (productId) {
                    Navigator.pop(context);
                    _showProductDetails(context, productId);
                  },
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
        return CreateCartDialog(
          onCreateCart: (List<CartItem> items) {
            context.read<CartBloc>().add(CreateCartEvent(products: items));
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
