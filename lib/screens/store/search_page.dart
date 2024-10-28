import 'package:flutter/material.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/product_service.dart'; // Asegúrate de importar el servicio
import 'product_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductSearchPage extends StatefulWidget {
  final Cart cart; // Recibe el carrito como parámetro

  const ProductSearchPage({super.key, required this.cart});

  @override
  ProductSearchPageState createState() => ProductSearchPageState();
}

class ProductSearchPageState extends State<ProductSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = []; // Lista para almacenar todos los productos
  String? _selectedCategory; // Variable para almacenar la categoría seleccionada
  List<String> _categories = []; // Lista de categorías

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchProducts(); // Cargar productos al iniciar
  }

  Future<void> _fetchProducts() async {
    try {
      List<Product> products = await ProductService().fetchProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products; // Inicialmente, todos los productos están filtrados
        _categories = _getCategories(products); // Obtener categorías de los productos
      });
    } catch (e) {
      // Manejar errores al obtener productos
      print('Error al obtener productos: $e');
    }
  }

  List<String> _getCategories(List<Product> products) {
    // Obtener una lista única de categorías
    return products.map((product) => product.category).toSet().toList();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  _filterProducts(); // Filtrar productos al cambiar la categoría
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
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
                        ? Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
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
                        ).animate().fadeIn(duration : 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                        Text(
                          'Precio: \$${product.price}',
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
                      // Navegar a la página de detalles del producto
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            cart: widget.cart, // Pasa el carrito actual
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