import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/my_app_state.dart';
import '../../services/product_service.dart';
import 'product_detail_screen.dart';
import 'search_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductScreen extends StatefulWidget {
  final Cart cart;

  ProductScreen({required this.cart});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _products = await ProductService().fetchProducts();
    setState(() {}); // Actualiza el estado una vez que los productos se cargan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
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
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.5,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ChangeNotifierProvider.value(
                    value: context.read<MyAppState>(),
                    child: ProductCard(product: product, cart: widget.cart),
                  ).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut).slide(duration: 300.ms, curve: Curves.easeInOut);
                },
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Cart cart;

  ProductCard({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, appState, child) {
        final isFavorite = appState.isFavorite(product);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product, cart: cart),
              ),
            );
          },
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.error)); // Manejar error de carga
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$ ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    appState.toggleFavorite(product);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}