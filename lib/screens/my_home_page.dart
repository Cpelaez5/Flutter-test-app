import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cart.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/widgets/navigation_rail.dart';
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
  final Cart cart = Cart(); // Instancia persistente del carrito
  String? userRole; // Variable para almacenar el rol del usuario

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Llamar al método para obtener el rol del usuario
  }

  Future<void> _getUserRole() async {
    final authService = AuthService();
    final user = authService.currentUser ;
    if (user != null) {
      userRole = await authService.getRole(user.uid);
      if (mounted) { // Verifica si el widget sigue montado
        setState(() {}); // Actualizar el estado para reflejar el rol
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ProductScreen(cart: cart); // Usar el carrito compartido
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = ProductSearchPage(cart: cart);
        break;
      case 3:
        page = UserScreen();
        break;
      case 4:
        if (userRole == 'cliente') { // Mostrar solo si el rol es administrador
          page = CartScreen(cart: cart); // Usar el carrito compartido
        } else {
          page = AdminScreen();
        }
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
            userRole: userRole,
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}