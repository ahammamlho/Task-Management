import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:management/dto/notification_dto.dart';
import 'package:management/sql/sql_database.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await localNotificationsPlugin.initialize(initializationSettings);

    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "channelId",
          "channelName",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails());

    await localNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "channelId",
          "channelName",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails());

    await localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  static Future<void> removeScheduleNotification({required int id}) async {
    await localNotificationsPlugin.cancel(id);
  }

  static Future<void> scheduleNotificationByUser(
      {required String idUser}) async {
    List<NotificationDto> notifs =
        await TaskDatabase.instance.getAllNotifications(idUser);
    for (NotificationDto notif in notifs) {
      if (notif.launchDate.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: notif.notificationId,
          title: "Approaching Deadline",
          body: notif.body,
          scheduledDate: notif.launchDate,
        );
      }
    }
  }

  static Future<void> cancelNotificationByUser({required String idUser}) async {
    List<NotificationDto> notifs =
        await TaskDatabase.instance.getAllNotifications(idUser);
    for (NotificationDto notif in notifs) {
      if (notif.isRead == 0) {
        await removeScheduleNotification(id: notif.notificationId);
      }
    }
  }
}
