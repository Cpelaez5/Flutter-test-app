import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Importar el paquete
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'product_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async'; // Para el debounce

class ProductSearchPage extends StatefulWidget {
  final Cart cart;

  const ProductSearchPage({super.key, required this.cart});

  @override
  ProductSearchPageState createState() => ProductSearchPageState();
}

class ProductSearchPageState extends State<ProductSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  String? _selectedCategory;
  List<String> _categories = [];
  Timer? _debounce; // Timer para el debounce

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // Solo carga los productos una vez
      if (_allProducts.isEmpty) {
        List<Product> products = await ProductService().fetchProducts();
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _categories = _getCategories(products);
        });
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  List<String> _getCategories(List<Product> products) {
    return products.map((product) => product.category).toSet().toList();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesQuery = product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Cancelar el debounce al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Buscar producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Dropdown para seleccionar categoría
            DropdownButton<String>(
              hint: Text('Seleccionar categoría'),
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  _filterProducts();
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar productos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];

                  return ListTile(
                    leading: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url ) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          )
                        : null,
                    title: Text(product.name).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.description.length > 50
                              ? '${product.description.substring(0, 50)}...'
                              : product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                        Text(
                          'Precio: Bs. ${(product.price).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        setState(() {
                          widget.cart.addProduct(product);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} agregado al carrito')),
                        );
                      },
                    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            cart: widget.cart,
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}