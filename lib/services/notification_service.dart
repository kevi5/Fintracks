import 'package:FinTrack/main.dart';
import 'package:FinTrack/pages/transaction_page.dart';
import 'package:FinTrack/util/value_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static const String channelId = 'FinTrack';
  static const String channelName = 'FinTrack';
  static const String channelDescription = 'FinTrack';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? notificationPayload;

  /// Initialize notification
  init() async {
    _configureLocalTimeZone();
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  onSelectNotification(NotificationResponse notificationResponse) async {
    String? payloadData = notificationResponse.payload;
    notificationPayload = payloadData;
    runNotificationPayLoadsNoContext(payloadData);
  }

  runNotificationPayLoadsNoContext(payloadData) {
    if (payloadData == "addTransaction") {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => TransactionPage(),
        ),
      );
    } else {
      print('No payload');
    }
    notificationPayload = "";
  }

  tz.TZDateTime _nextInstanceOfSetTime(TimeOfDay timeOfDay,
      {int dayOffset = 0}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // add one to current day (if app wasn't opened, it will notify)
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day + dayOffset, timeOfDay.hour, timeOfDay.minute);

    return scheduledDate;
  }

  Future<bool> scheduleDailyNotification(TimeOfDay timeOfDay,
      {bool scheduleNowDebug = false}) async {
    // If the app was opened on the day the notification was scheduled it will be
    // cancelled and set to the next day because of _nextInstanceOfSetTime
    // If ReminderNotificationType.Everyday is not true
    await cancelDailyNotification();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'transactionReminders',
      'Transaction Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: 'transactionReminders');

    // schedule 2 weeks worth of notifications
    for (int i = 0; i <= 14; i++) {
      String chosenMessage = "Don't forget to add transactions from today!";
      tz.TZDateTime dateTime = _nextInstanceOfSetTime(timeOfDay, dayOffset: i);
      if (scheduleNowDebug) {
        dateTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: i * 5));
      }
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'Add Transaction',
        chosenMessage,
        dateTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        payload: 'addTransaction',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,

        // If exact time was used, need USE_EXACT_ALARM and SCHEDULE_EXACT_ALARM permissions
        // which are only meant for calendar/reminder based applications
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print("Notification " +
          chosenMessage +
          " scheduled for " +
          dateTime.toString() +
          " with id " +
          i.toString());
    }

    // final List<PendingNotificationRequest> pendingNotificationRequests =
    //     await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    return true;
  }

  Future<bool> cancelDailyNotification() async {
    // Need to cancel all, including the one at 0 - even if it does not exist
    for (int i = 0; i <= 14; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
    print("Cancelled notifications for daily reminder");
    return true;
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertTime(
      int day, int month, int year, int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    print('scheduled:::: $scheduleDate');
    if (scheduleDate.isBefore(now)) {
      scheduleDate = now.add(const Duration(seconds: 3));
    }
    print('$now and $scheduleDate');
    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterTimezone.getLocalTimezone();
    print(timeZone);
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  Future showNotificationAndroid(String title, String value) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      icon: "@mipmap/ic_launcher",
    );

    int notification_id = 1;
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notification_id, title, value, notificationDetails,
        payload: 'Not present');
  }

  /// Scheduled Notification
  scheduledNotification({
    required int hour,
    required int minutes,
    required int id,
    required String sound,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'It\'s time to drink water!',
      'After drinking, touch the cup to confirm',
      _convertTime(0, 0, 0, hour, minutes),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'It could be anything you pass',
    );
  }

  /// Request IOS permissions
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();
  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);
}
