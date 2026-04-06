import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notes/Components/Splash.dart';
import 'package:notes/Services/comman.dart';
import 'package:notes/Services/global.dart';
import 'package:notes/Services/theme.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Pages/home.dart' as home;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(UncontrolledProviderScope(container: container, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  final theme = AppTheme;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsData = ref.watch(dataprovider);
    final theme = settingsData['theme'] ?? 'System';
    final mode = theme == 'System'
        ? ThemeMode.system
        : theme == 'Light'
        ? ThemeMode.light
        : ThemeMode.dark;
    Color navColor = ElevationOverlay.applySurfaceTint(
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.surfaceTint,
      3,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider('light')),
      darkTheme: ref.watch(themeProvider('dark')),
      themeMode: mode,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        final theme = Theme.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: child!,
        );
      },
      home: SplashScreen(),
    );
  }
}
