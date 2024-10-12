import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/products.dart';
import 'package:flutter_application_1/pages/product_screen.dart';
import 'package:provider/provider.dart';
import './pages/favorites_page.dart';
import './pages/search_page.dart';
import 'models/cart.dart';
import 'models/product.dart';
import 'pages/auth_screen.dart';
import 'pages/cart_screen.dart';
import 'pages/webview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MyAppState()), // Añade MyAppState aquí
      ],
      child: MaterialApp(
        title: 'Cafetín Ibero',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return MyHomePage(); // Usuario autenticado
        } else {
          return AuthScreen(); // Usuario no autenticado
        }
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Product> favorites = [];
  Product? currentProduct;

  void initializeCurrentProduct() {
    if (products.isNotEmpty) {
      currentProduct = products.first; // O cualquier lógica que necesites
    }
  }

  bool isFavorite(Product product) {
    return favorites.contains(product);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      favorites.remove(product);
    } else {
      favorites.add(product);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  final Cart cart = Cart(); // Instancia persistente del carrito

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
        page = ProductSearchPage(products: products, cart: cart);
        break;
      case 3:
        page = WebViewScreen(initialUrl: 'https://le-petit.labrioche.com.ve/');
        break;
      case 4:
        page = CartScreen(cart: cart); // Usar el carrito compartido
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.storefront),
                      label: Text('Shop'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text('Search'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.web_asset),
                      label: Text('Web'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Cart'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value ) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
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
      },
    );
  }
}