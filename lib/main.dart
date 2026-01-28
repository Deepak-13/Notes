
import 'package:app_v1/Provider/comman.dart';
import 'package:app_v1/Provider/theme.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Pages/home.dart' as home;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =AndroidInitializationSettings('app_icon');
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

