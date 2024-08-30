import 'package:FinTrack/pages/categories_page.dart';
import 'package:FinTrack/pages/helper/themes.dart';
import 'package:FinTrack/pages/home_page.dart';
import 'package:FinTrack/pages/recurring_page.dart';
import 'package:FinTrack/pages/settings_page.dart';
import 'package:FinTrack/pages/trash_page.dart';
import 'package:FinTrack/pages/transaction_page.dart';
import 'package:FinTrack/services/notification_service.dart';
import 'package:FinTrack/services/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await SettingsProvider().getPreferences();
  await GetStorage.init();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
          builder: (context, SettingsProvider themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          navigatorKey: navigatorKey,
          theme: themeNotifier.isDarkMode ? Themes.dark : Themes.light,
          darkTheme: themeNotifier.isDarkMode ? Themes.dark : Themes.light,
          routes: {
            '/': (context) => const HomePage(),
            '/transactions': (context) => const TransactionPage(),
            '/categories': (context) => const CategoriesPage(),
            '/settings': (context) => const SettingsPage(),
            '/recurring': (context) => const RecurringPage(),
            '/trash': (context) => const TrashPage(),
          },
        );
      }),
    );
  }
}
