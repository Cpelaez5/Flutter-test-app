import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cart.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/screens/store/product_screen.dart';
import 'package:flutter_application_1/screens/client/favorites_page.dart';
import 'package:flutter_application_1/screens/store/search_page.dart';
import 'package:flutter_application_1/screens/users/user_screen.dart';
import 'package:flutter_application_1/screens/admin/admin_screen.dart';
import 'package:flutter_application_1/screens/client/cart_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  final Cart cart = Cart();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final authService = AuthService();
    final user = authService.currentUser ;
    if (user != null) {
      userRole = await authService.getRole(user.uid);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _getPage() {
    switch (selectedIndex) {
      case 0:
        return ProductScreen(cart: cart);
      case 1:
        return FavoritesPage();
      case 2:
        return ProductSearchPage(cart: cart);
      case 3:
        return UserScreen();
      case 4:
        return userRole == 'cliente' ? CartScreen(cart: cart) : AdminScreen();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200], // Color de fondo gris
        child: Column(
          children: [
            Expanded(
              child: _getPage(),
            ),
            BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_rounded),
                  label: 'Productos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Usuario',
                ),
                if (userRole == 'cliente') // Mostrar solo si el rol es cliente
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Carrito',
                  ),
                if (userRole == 'administrador') // Mostrar solo si el rol es administrador
                  BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings),
                    label: 'Administración',
                  ),
              ],
              backgroundColor: Theme.of(context).colorScheme.primary, // Color de fondo de la barra
              selectedItemColor: Colors.brown, // Color del ítem seleccionado
              unselectedItemColor: Colors.brown, // Color del ítem no seleccionado
            ),
          ],
        ),
      ),
    );
  }
}