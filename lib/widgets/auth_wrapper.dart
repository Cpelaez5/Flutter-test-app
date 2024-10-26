import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/users/auth_screen.dart';
import '../screens/my_home_page.dart';
import '../services/auth_service.dart';
import '../services/my_app_state.dart';

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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<MyAppState>(context, listen: false).loadFavorites();
            });
          }
          return MyHomePage();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<MyAppState>(context, listen: false).clearFavorites();
          });
          return AuthScreen();
        }
      },
    );
  }
}
