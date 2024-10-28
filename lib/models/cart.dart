import 'product.dart';

class Cart {
  final List<Product> _products = [];

  List<Product> get products => _products;

  void addProduct(Product product) {
    // Buscamos si el producto ya existe en el carrito
    int index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // Si existe, incrementamos la cantidad
      _products[index].quantity++;
    } else {
      // Si no existe, agregamos el producto con cantidad 1
      product.quantity = 1; // Asegúrate de que quantity esté inicializado
      _products.add(product);
    }
  }

  void removeProduct(Product product) {
    // Buscamos el producto en el carrito
    int index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      // Si existe, decrementamos la cantidad
      _products[index].quantity--;
      if (_products[index].quantity == 0) {
        // Si la cantidad es 0, eliminamos el producto del carrito
        _products.removeAt(index);
      }
    }
  }

  void clear() {
    _products.clear();
  }

  double get totalPrice {
    // Calcula el precio total del carrito
    double total = 0.0;
    for (var product in _products) {
      total += product.price * product.quantity; // Multiplica el precio por la cantidad
    }
    return total;
  }
}