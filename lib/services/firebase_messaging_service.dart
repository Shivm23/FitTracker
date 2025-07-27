import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/core/domain/usecase/add_macro_goal_usecase.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/domain/entity/user_role_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './local_notifications_service.dart';
import 'package:logging/logging.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  final Logger log = Logger('FirebaseMessagingService');

  LocalNotificationsService? _localNotificationsService;

  Future<void> init(
      {required LocalNotificationsService localNotificationsService}) async {
    log.fine('[🔥] Initialisation FirebaseMessagingService démarrée');

    _localNotificationsService = localNotificationsService;

    await _handlePushNotificationsToken();
    await _requestPermission();

    log.fine('[🟡] Enregistrement du handler background...');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    log.fine('[🟢] Écoute des messages en foreground...');
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    log.fine(
        '[🟣] Écoute des messages quand l\'app est ouverte via notification...');
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log.fine('[🟠] App ouverte via une notification depuis état TERMINÉ.');
      _onMessageOpenedApp(initialMessage);
    } else {
      log.fine('[⚪] Aucune notification à l’ouverture.');
    }

    log.fine('[✅] Initialisation FirebaseMessagingService terminée');
  }

  Future<void> _handlePushNotificationsToken() async {
    log.fine('[🔑] Récupération du token FCM...');
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      log.fine('[✅] Token FCM obtenu: $token');

      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;

        if (userId == null) {
          log.severe(
              '[❌] Utilisateur non authentifié, impossible de mettre à jour le token.');
          return;
        }

        log.fine('[📬] Mise à jour du token dans Supabase pour user: $userId');

        await Supabase.instance.client.from('user_devices').upsert({
          'user_id': userId,
          'fcm_token': token,
        }, onConflict: 'user_id');

        log.fine('[✅] Token FCM mis à jour dans Supabase');
      } catch (e, stack) {
        log.fine('[🔥] UPDATE Erreur lors de l\'update FCM dans Supabase: $e');
        log.fine(stack.toString());
      }
    } else {
      log.fine('[❌] Token FCM est nul');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      log.fine('[♻️] Token FCM rafraîchi: $fcmToken');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        log.warning('[⚠️] Utilisateur non authentifié lors du refresh');
        return;
      }

      try {
        await Supabase.instance.client.from('user_devices').upsert({
          'user_id': userId,
          'fcm_token': fcmToken,
        }, onConflict: 'user_id');
        log.fine('[✅] Nouveau token FCM mis à jour après refresh');
      } catch (e, stack) {
        log.severe('[🔥] Erreur lors du refresh FCM dans Supabase: $e');
        log.severe(stack.toString());
      }
    }).onError((error) {
      log.severe('[❌] Erreur lors du rafraîchissement du token FCM: $error');
    });
  }

  Future<void> _requestPermission() async {
    log.fine('[🔐] Demande de permission utilisateur...');
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log.fine('[📋] Résultat permission: ${result.authorizationStatus}');
    switch (result.authorizationStatus) {
      case AuthorizationStatus.authorized:
        log.fine('[✅] Notifications AUTORISÉES');
        break;
      case AuthorizationStatus.denied:
        log.warning('[🚫] Notifications REFUSÉES');
        break;
      case AuthorizationStatus.notDetermined:
        log.warning('[❓] Autorisation non déterminée');
        break;
      case AuthorizationStatus.provisional:
        log.fine('[🟡] Autorisation provisoire');
        break;
    }
  }

  void _onForegroundMessage(RemoteMessage message) async {
    log.fine('[📥] Message reçu en foreground');
    log.fine(
        '🔸 Notification: ${message.notification?.title} - ${message.notification?.body}');
    log.fine('🔸 Données: ${message.data}');

    final notificationData = message.notification;
    if (notificationData != null) {
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    } else {
      log.warning('[⚠️] Aucune donnée de notification à afficher');
    }

    // If a student received a notification, update macro goals
    final user = await locator.get<GetUserUsecase>().getUserData();
    if (user.role == UserRoleEntity.student) {
      try {
        await locator.get<AddMacroGoalUsecase>().addMacroGoalFromCoach();
        log.fine('[✅] Objectifs macro mis à jour depuis Supabase');
        // Refresh Home Page
        locator<HomeBloc>().add(const LoadItemsEvent());
        // Refresh Diary Page
        locator<DiaryBloc>().add(const LoadDiaryYearEvent());
        locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
      } catch (e, stack) {
        log.warning('[❌] Erreur lors de la mise à jour des macros : $e');
        log.warning(stack.toString());
      }
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) async {
    log.fine('[📲] Notification tapée - app ouverte');
    log.fine('🔸 Données: ${message.data}');
    // TODO: Add navigation or specific handling
    // If a student received a notification, update macro goals
    final user = await locator.get<GetUserUsecase>().getUserData();
    if (user.role == UserRoleEntity.student) {
      try {
        await locator.get<AddMacroGoalUsecase>().addMacroGoalFromCoach();
        log.fine('[✅] Objectifs macro mis à jour depuis Supabase');
        // Refresh Home Page
        locator<HomeBloc>().add(const LoadItemsEvent());
        // Refresh Diary Page
        locator<DiaryBloc>().add(const LoadDiaryYearEvent());
        locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
      } catch (e, stack) {
        log.warning('[❌] Erreur lors de la mise à jour des macros : $e');
        log.warning(stack.toString());
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final log = Logger('FCMBackgroundHandler');
  log.fine('[📤] Message reçu en background');
  log.fine('🔸 Données: ${message.data}');
}
