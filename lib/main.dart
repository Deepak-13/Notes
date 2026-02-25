
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notes/Provider/comman.dart';
import 'package:notes/Provider/global.dart';
import 'package:notes/Provider/theme.dart';
import 'package:flutter/material.dart' hide Theme, Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Pages/home.dart' as home;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  final String timeZoneName = timeZoneInfo.identifier;
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  final notification = NotificationService();
  await notification.initializeNotification();
  runApp(
    ProviderScope(
      child:MyApp()
    ));
}



class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  final theme=AppTheme;
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    
    final initializationStatus = ref.watch(initializationProvider);
    final settingsData = ref.watch(dataprovider);
    final theme = settingsData['theme'] ?? 'Default';
    final mode = theme=='Default'?ThemeMode.system:theme=='Light'?ThemeMode.light:ThemeMode.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      navigatorKey: navigatorKey,
      home: initializationStatus.when(
        data: (_) => const home.MyHomePage(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Error loading data: $err')), 
        ),
      )
    );
  }
}

