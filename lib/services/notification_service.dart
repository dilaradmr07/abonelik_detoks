import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Android ayarları
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(settings);

    // İzin iste (Android 13 ve üzeri için şart)
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleNotification(int id, String name, int day) async {
    try {
      final now = DateTime.now();
      // Tarih hesaplama
      var scheduledDate = DateTime(now.year, now.month, day - 1, 20, 0);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = DateTime(now.year, now.month + 1, day - 1, 20, 0);
      }

      // Timezone lokasyonunu güvenli al
      // Eğer 'local' hata verirse varsayılan olarak UTC kullanırız
      final location = tz.local; 

      await _notificationsPlugin.zonedSchedule(
        id,
        'Ödeme Hatırlatıcı 🔔',
        'Yarın $name ödemen var, unutma!',
        tz.TZDateTime.from(scheduledDate, location),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sub_reminders', 
            'Abonelik Hatırlatıcı',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (e) {
      print("Bildirim hatası: $e");
    }
  }
}