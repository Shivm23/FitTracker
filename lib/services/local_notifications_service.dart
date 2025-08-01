import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class LocalNotificationsService {
  LocalNotificationsService._internal();
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService.instance() => _instance;

  final Logger log = Logger('LocalNotificationsService');

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  bool _isFlutterLocalNotificationInitialized = false;
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android and iOS.
  Future<void> init() async {
    if (_isFlutterLocalNotificationInitialized) {
      log.fine('[🔁] Local notifications déjà initialisées.');
      return;
    }

    log.fine('[🚀] Initialisation de FlutterLocalNotificationsPlugin...');
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log.fine(
            '[📲] Notification tapée (foreground) - payload: ${response.payload}');
        // TODO: Ajouter une navigation si nécessaire
      },
    );

    log.fine('[📡] Création du canal de notifications Android...');
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _isFlutterLocalNotificationInitialized = true;
    log.info('[✅] Plugin local notifications initialisé avec succès.');
  }

  /// Show a local notification with the given title, body, and payload.
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    log.fine('[🔔] Affichage notification locale: "$title" - "$body"');

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        _notificationIdCounter++,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      log.fine(
          '[✅] Notification affichée avec succès (ID: ${_notificationIdCounter - 1})');
    } catch (e) {
      log.severe('[❌] Erreur lors de l\'affichage de la notification: $e');
    }
  }
}
