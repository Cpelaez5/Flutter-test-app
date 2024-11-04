import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../preferences/pref_usuarios.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(NotificationsInitial()) {

  _onForegroundMessage();
  }


  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    settings.authorizationStatus;
    _getToken();
  }

  void _getToken() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final settings = await messaging.getNotificationSettings();
  
  if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

  final token = await messaging.getToken();

    if (token != null) {
      final prefs = PreferenciasUsuario();
      prefs.token = token;

      // Aquí debes obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser ?.uid ?? '';// Reemplaza esto con el ID del usuario actual

      // Referencia al documento del usuario en Firestore
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Actualizar el campo de tokens
      await userDoc.set({
        'tokens': FieldValue.arrayUnion([token]) // Agrega el nuevo token al arreglo
      }, SetOptions(merge: true)); // merge: true para no sobrescribir otros campos
    }
  }

  //metodo para estar pendiente de los mensajes en primer plano
  void _onForegroundMessage(){
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void handleRemoteMessage(RemoteMessage message) {
    var mensaje = message.data;
    var body = mensaje['body'];
    var title = mensaje['title'];

    
  }
}