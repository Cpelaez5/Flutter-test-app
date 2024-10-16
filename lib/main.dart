import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './data/products.dart';
import 'screens/store/product_screen.dart';
import 'package:provider/provider.dart';
import 'screens/client/favorites_page.dart';
import 'screens/store/search_page.dart';
import 'models/cart.dart';
import 'models/product.dart';
import 'screens/admin/admin_order_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/users/auth_screen.dart';
import 'screens/client/cart_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/users/user_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   timeago.setLocaleMessages('es', timeago.EsMessages());
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
        ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: MaterialApp(
        title: 'Cafetín Ibero',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreenWrapper(),
          '/login': (context) => AuthScreen(),
          '/home': (context) => MyHomePage(),
          '/admin': (context) => AdminScreen(),
          '/orders': (context) => AdminOrderScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => NotFoundScreen());
        },
      ),
    );
  }
}

// Clase de ejemplo para la pantalla de pedidos
class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      body: Center(
        child: Text('Aquí se mostrarán los pedidos.'),
      ),
    );
  }
}

// Clase de ejemplo para la pantalla de no encontrado
class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No Encontrado'),
      ),
      body: Center(
        child: Text('La página que buscas no existe.'),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
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
          final user = snapshot.data;
          if (user != null) {
            print('Usuario autenticado: ${user.uid}'); // Depuración
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<MyAppState>(context, listen: false).loadFavorites();
            });
          }
          return MyHomePage();
        } else {
          print('Usuario no autenticado'); // Depuración
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<MyAppState>(context, listen: false).clearFavorites();
          });
          return AuthScreen();
        }
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Product> favorites = [];

  bool isFavorite(Product product) {
    return favorites.any((fav) => fav.id == product.id);
  }

  Future<void> toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    final userFavoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    if (isFavorite(product)) {
      favorites.removeWhere((fav) => fav.id == product.id);
      await userFavoritesRef.doc(product.id.toString()).delete();
    } else {
      favorites.add(product);
      await userFavoritesRef.doc(product.id.toString()).set({
        'id': product.id,
      });
    }

    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    print('Cargando favoritos para el usuario: ${user.uid}'); // Depuración

    final userFavoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    final snapshot = await userFavoritesRef.get();
    final favoriteIds = snapshot.docs.map((doc) => int.parse(doc.id)).toList();

    favorites = products.where((product) => favoriteIds.contains(product.id)).toList();

    print('Favoritos cargados: ${favorites.length}'); // Depuración
    notifyListeners();
  }

  void clearFavorites() {
    favorites.clear();
    print('Favoritos limpiados'); // Depuración
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
      setState(() {}); // Actualizar el estado para reflejar el rol
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
        page = ProductSearchPage(products: products, cart: cart);
        break;
      case 3:
        page = UserProfileScreen();
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
                      icon: Icon(Icons.person),
                      label: Text('User  Profile'),
                    ),
                    if (userRole == 'cliente') // Mostrar solo si el rol es cliente
                      NavigationRailDestination(
                        icon: Icon(Icons.shopping_cart),
                        label: Text('Cart'),
                    ),
                    if (userRole == 'administrador') // Mostrar solo si el rol es administrador
                      NavigationRailDestination(
                        icon: Icon(Icons.admin_panel_settings),
                        label: Text('Admin'),
                      ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
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