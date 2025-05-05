# Flutter E-Commerce App

A comprehensive Flutter e-commerce application built with Clean Architecture and BLoC state management. This app provides user authentication, product browsing, and cart management functionality using the FakeStoreAPI.

## Project Overview

This e-commerce application demonstrates best practices in Flutter development, including:

- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: Reactive state management using the flutter_bloc package
- **RESTful API Integration**: Using Dio for network requests to FakeStoreAPI
- **Responsive UI**: Works across different screen sizes
- **Error Handling**: Comprehensive error handling with user feedback

## Architecture Overview

### Clean Architecture

The project follows Clean Architecture principles with three main layers:

1. **Domain Layer**: Contains business logic, entities, and use cases

   - Entities: User, Product, Cart, CartItem
   - Repositories (interfaces): AuthRepository, ProductRepository, CartRepository
   - Use Cases: AuthUseCase, ProductUseCase, CartUseCase

2. **Data Layer**: Implements repositories and handles data sources

   - Repository Implementations: AuthRepositoryImpl, ProductRepositoryImpl, CartRepositoryImpl
   - Data Sources: ApiClient for FakeStoreAPI integration

3. **Presentation Layer**: UI components and state management
   - BLoCs: AuthBloc, ProductBloc, CartBloc, CartItemBloc
   - Pages: LoginPage, CartPage
   - Widgets: ProductDialog, CreateCartDialog, CartItemWidget

### BLoC Pattern

Each feature has its own BLoC with:

- Events: User actions that trigger state changes
- States: Different UI states (loading, loaded, error)
- BLoC: Business logic that processes events and emits states

## Setup Instructions

1. **Prerequisites**:

   - Flutter SDK (latest stable version)
   - Dart SDK
   - Android Studio / VS Code with Flutter plugins

2. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd flutter-ecommerce-app
   ```

3. **Install dependencies**:

   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## Features Implemented

### Authentication

- User login with username and password
- Session management
- Error handling for authentication failures

### Product Management

- Fetch and display products from FakeStoreAPI
- Product details view
- Product search functionality

### Cart Management

- Create new carts
- Add products to cart with quantity
- Edit cart items (update quantity)
- Remove items from cart
- View cart details with product information
- Pagination for cart items table
- Cart item management with dedicated BLoC

## Features Checklist

- [x] User Authentication

  - [x] Login functionality
  - [x] Logout functionality
  - [x] Snackbar notification functionality

- [x] Cart Management

  - [x] Cart Page after login
  - [x] Cart pagination
  - [x] See product information on each cart
  - [x] Filter by date
  - [x] Create new cart
  - [x] Snackbar on cart created

## Dependencies

The project uses the following key dependencies:

- **flutter_bloc**: State management using the BLoC pattern
- **dio**: HTTP client for API requests
- **intl**: Internationalization and formatting

## Usage Instructions

### Authentication

1. Launch the app
2. Enter any username and password on the login screen
3. Press "Login" to authenticate

### Managing Products

1. Navigate to the products section
2. Browse available products
3. Select a product to view details

### Managing Cart

1. Navigate to the cart section
2. Click "Create New Cart" to start a new cart
3. Use the product selector to find products
4. Enter quantity and click "Add to Cart"
5. Edit quantities by clicking the edit icon
6. Remove items by clicking the delete icon
7. Use pagination controls to navigate through cart items

## Testing

No tests were added for this project

## Acknowledgements

- [FakeStoreAPI](https://fakestoreapi.com/) for providing the product data
