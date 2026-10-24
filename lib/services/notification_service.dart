import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  DateTime? _lastAlertNotificationTime;

  static const String channelId = 'noiseguard_alerts';
  static const String channelName = 'NoiseGuard Violation Alerts';
  static const String channelDescription = 'Instant notifications when noise levels exceed safety thresholds';

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel with High Importance & Vibration
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        );

        // Request notification permission for Android 13+
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  Future<void> showNoiseAlert({
    required double noiseLevel,
    required double threshold,
    required String source,
    required String address,
    int debounceSeconds = 8,
  }) async {
    // Throttle notifications to prevent notification spam
    final now = DateTime.now();
    if (_lastAlertNotificationTime != null &&
        now.difference(_lastAlertNotificationTime!).inSeconds < debounceSeconds) {
      return;
    }
    _lastAlertNotificationTime = now;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      styleInformation: const BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final title = '🚨 Noise Alert: ${noiseLevel.toStringAsFixed(1)} dB ($source)';
    final body = 'Noise exceeded ${threshold.toStringAsFixed(1)} dB limit at $address';

    try {
      await _notificationsPlugin.show(
        now.millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: 'alert_$now',
      );
      debugPrint('Triggered Noise Notification: $title');
    } catch (e) {
      debugPrint('Error displaying notification: $e');
    }
  }
}
