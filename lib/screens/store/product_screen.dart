// product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/my_app_state.dart';
import '../../services/products/product_service.dart';
import '../../widgets/store/product_card.dart';
import 'search_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductScreen extends StatefulWidget {
  final Cart cart;

  const ProductScreen({required this.cart, Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  late Future<String> _userRoleFuture; // Para obtener el rol del usuario

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _userRoleFuture = ProductService().getUserRole(); // Obtener el rol del usuario
  }

  Future<List<Product>> _loadProducts() async {
    return await ProductService().fetchProducts();
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Icono de actualización
            onPressed: () {
              setState(() {
                _productsFuture = _loadProducts(); // Recargar productos
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSearchPage(cart: widget.cart),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar productos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }

          final products = snapshot.data!;

          return FutureBuilder<String>(
            future: _userRoleFuture,
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (roleSnapshot.hasError) {
                return const Center(child: Text('Error al obtener el rol del usuario'));
              } else if (!roleSnapshot.hasData) {
                return const Center(child: Text('No se pudo obtener el rol'));
              }

              final userRole = roleSnapshot.data!; // Obtener el rol del usuario

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.5,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ChangeNotifierProvider.value(
                      value: context.read<MyAppState>(),
                      child: ProductCard(product: product, cart: widget.cart, userRole: userRole), // Pasar el rol del usuario
                    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).slide(duration: 300.ms, curve: Curves.easeInOut);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}