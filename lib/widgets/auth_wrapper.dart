import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/my_home_page.dart';
import '../services/auth/auth_service.dart';
import '../services/my_app_state.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return _handleAuthState(context, snapshot);
          default:
            return const Center(child: Text('Error desconocido'));
        }
      },
    );
  }

  Widget _handleAuthState(BuildContext context, AsyncSnapshot<User?> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      User? user = snapshot.data;
      if (user!.emailVerified) {
        // Cargar favoritos solo si el usuario está verificado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<MyAppState>(context, listen: false).loadFavorites();
        });
        return MyHomePage();
      } else {
        // Si el correo no está verificado, redirigir a AuthScreen
        return AuthScreen(
          verificationMessage: 'Por favor verifica tu correo electrónico antes de iniciar sesión.',
        );
      }
    } else {
      // Si no hay usuario autenticado, limpiar favoritos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MyAppState>(context, listen: false).clearFavorites();
      });
      return AuthScreen();
    }
  }
}