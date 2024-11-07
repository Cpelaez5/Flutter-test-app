import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/preferences/pref_usuarios.dart';
import 'package:flutter_application_1/screens/splash_screen.dart'; // Mantén la pantalla de splash
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/localNotification/local_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa el paquete dotenv
import 'firebase_options.dart';
import 'screens/my_home_page.dart';
import 'screens/not_found_screen.dart';
import 'services/bloc/notifications_bloc.dart';
import 'services/my_app_state.dart';
import 'screens/users/user_profile_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/admin_order_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar el archivo .env
  await dotenv.load(fileName: ".dotenv");

  timeago.setLocaleMessages('es', timeago.EsMessages());
  Intl.defaultLocale = 'es_ES';
  await PreferenciasUsuario.init();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotification.initializeLocalNotifications();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotificationsBloc()),
      ],
      child: MyApp(),
    ),
  );
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
        title: 'Mi Cantina',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: SplashScreenWrapper(),
        routes: {
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