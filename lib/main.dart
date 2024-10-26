import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/my_home_page.dart';
import 'screens/not_found_screen.dart';
import 'services/my_app_state.dart';
import 'screens/users/auth_screen.dart';
import 'screens/users/user_profile_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/admin_order_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('es', timeago.EsMessages());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        title: 'Mi Cafetín',
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
          '/profile': (context) => UserProfileScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => NotFoundScreen()),
      ),
    );
  }
}