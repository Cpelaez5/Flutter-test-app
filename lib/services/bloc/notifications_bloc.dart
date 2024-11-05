import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../preferences/pref_usuarios.dart';
import '../localNotification/local_notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler( RemoteMessage message) async {
    var mensaje = message.data;
    var body = mensaje['body'] ?? 'No hay cuerpo';
    var title = mensaje['title'] ?? 'Sin título';

    Random random = Random();
    var id = random.nextInt(100000);

    LocalNotification.showLocalNotification(
      id: id,
      title: title,
      body: body,
    );
  }

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsInitial()) {
    _onForegroundMessage();
  }

  void requestPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      await LocalNotification.requestPermissionLocalNotifications();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _getToken();
      } else {
        print('Permisos de notificación no autorizados.');
      }
    } catch (e) {
      print('Error al solicitar permisos de notificación: $e');
    }
  }

  void _getToken() async {
    final settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();

    if (token != null) {
      final prefs = PreferenciasUsuario();
      prefs.token = token;

      // Obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser ?.uid ?? '';

      // Referencia al documento del usuario en Firestore
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Actualizar el campo de tokens
      await userDoc.set({
        'tokens': FieldValue.arrayUnion([token]) // Agrega el nuevo token al arreglo
      }, SetOptions(merge: true)); // merge: true para no sobrescribir otros campos
    }
  }

  // Método para estar pendiente de los mensajes en primer plano
  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  // Método para manejar mensajes en segundo plano

  void handleRemoteMessage(RemoteMessage message) {
    var mensaje = message.data;
    var body = mensaje['body'] ?? 'No hay cuerpo';
    var title = mensaje['title'] ?? 'Sin título';

    Random random = Random();
    var id = random.nextInt(100000);

    LocalNotification.showLocalNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  // Método para revocar el token al cerrar sesión
  Future<void> revokeToken() async {
    String userId = FirebaseAuth.instance.currentUser ?.uid ?? '';
    if (userId.isNotEmpty) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDoc.update({
        'tokens': FieldValue.arrayRemove([PreferenciasUsuario().token]) // Remover el token actual
      });
    }
  }
}