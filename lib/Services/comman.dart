import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:notes/Pages/notes.dart';
import 'package:notes/Services/global.dart';
import 'package:notes/Services/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'global.dart';

typedef ImageCache = Map<int, List<Uint8List>>;
typedef NoteImageParams = ({int noteId, int? limit});

final dataprovider = NotifierProvider<DataNotifier, Map<String, dynamic>>(
  DataNotifier.new,
);

final noteprovider =
    NotifierProvider<NotesNotifier, List<Map<String, dynamic>>>(
      NotesNotifier.new,
    );

final lablesprovider =
    NotifierProvider<LablesNotifier, List<Map<String, dynamic>>>(
      LablesNotifier.new,
    );

final imageCacheProvider = NotifierProvider<ImageNotifier, ImageCache>(
  ImageNotifier.new,
);

final initializationProvider = FutureProvider<void>((ref) async {
  await ref.read(noteprovider.notifier).fetchfromstorage();
  await ref.read(dataprovider.notifier).fetchsettings();
});

final fetchLablesProvider = FutureProvider<void>((ref) async {
  await ref.read(lablesprovider.notifier).fetchfromstorage();
  ref.keepAlive();
});

final noteImagesProvider =
    FutureProvider.family<List<Uint8List>, NoteImageParams>((
      ref,
      params,
    ) async {
      final noteId = params.noteId;
      final cache = ref.watch(imageCacheProvider);
      if (cache.containsKey(noteId)) {
        final List<Uint8List> cachedImages = cache[noteId]!;
        return (params.limit != null && params.limit! < cachedImages.length)
            ? cachedImages.sublist(0, params.limit)
            : cachedImages;
      } else {
        return [];
      }
    });

final filteredListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final fullList = ref.watch(noteprovider);
  final query = ref.watch(dataprovider);
  if (query["txt"].trim().isEmpty ?? true) {
    return fullList;
  }

  final lowerCaseQuery = query['txt'].toLowerCase();

  return fullList.where((card) {
    final title = card['Title']?.toString().toLowerCase() ?? '';
    final content = card['Description']?.toString().toLowerCase() ?? '';
    print("title....$title.....$title.contains(lowerCaseQuery)");
    return title.contains(lowerCaseQuery) || content.contains(lowerCaseQuery);
  }).toList();
});

class DataNotifier extends Notifier<Map<String, dynamic>> {
  final db = SqfliteProvider.instance;

  @override
  build() {
    return {"view": 2, "txt": '', 'theme': 'System', 'color': 0xFFFFB300};
  }

  void search(String txt) {
    state = {...state, "txt": txt};
    print(state);
  }

  void updateSettings({int? view, String? theme, int? color}) {
    if (view != null) {
      db.updatesettings(view: view);
      state = {...state, "view": view};
    }
    if (theme != null) {
      db.updatesettings(theme: theme);
      state = {...state, "theme": theme};
    }
    if (color != null) {
      db.updatesettings(color: color);
      state = {...state, "color": color};
    }
  }

  Future<void> fetchsettings() async {
    final settings = await db.getSettings();
    state = {
      "view": settings['view'] ?? 2,
      "txt": '',
      'theme': settings['theme'] ?? 'System',
      'color': settings['color'] ?? 0xFFFFB300,
    };
  }
}

class NotesNotifier extends Notifier<List<Map<String, dynamic>>> {
  final db = SqfliteProvider.instance;
  final notify = NotificationService();
  @override
  build() {
    return [];
  }

  Future<void> fetchfromstorage() async {
    print("fetching from storage.....");
    state = await db.getallNotes();
    for (final note in state) {
      final noteId = note['id'] as int;
      final fileName = note['Imagefile'] as String;
      if (fileName.isEmpty) continue;
      final List<dynamic> datafromfile = await db.readImage(fileName);
      final List<Uint8List> decodedImages = datafromfile
          .map((item) => base64Decode(item))
          .toList();
      Future.microtask(
        () =>
            ref.read(imageCacheProvider.notifier).update(noteId, decodedImages),
      );
    }
  }

  Future<int> add(Map data) async {
    print(
      "adding to storage.....$data['reminder']...${data['reminderDateTime']}",
    );
    final noteId = await db.insertNote(
      data['title'],
      data['content'],
      '',
      data['pinned'],
      data['reminder'],
      data['reminder'] == 1 ? data['reminderDateTime'] : null,
      data['frequency'],
    );
    String name = data['img'].isNotEmpty ? "img_$noteId.json" : '';
    if (data['img'].isNotEmpty) {
      final List<String> image = data['img']
          .map<String>((item) => base64Encode(item))
          .toList();
      db.writeimg(image, name);
    }
    await db.updateImgFile(noteId, name);
    ref.read(imageCacheProvider.notifier).update(noteId, data['img']);
    final date = DateTime.now().toIso8601String();
    final newCard = {
      "Title": data['title'],
      "id": noteId,
      "Description": data['content'],
      "Imagefile": name,
      'Created_Date': date,
      'Modified_Date': date,
      'Pinned': data['pinned'] ?? 0,
      'Reminder': data['reminder'] ?? 0,
      'Frequency': data['frequency'] ?? 'Once',
      "ReminderDateTime":
          data['reminder'] == 1 && data['reminderDateTime'] != null
          ? (data['reminderDateTime'] as tz.TZDateTime).toIso8601String()
          : null,
    };
    print("Reminder.....${data['reminder']}");
    if (data['reminder'] == 1 && data['reminderDateTime'] != null) {
      notify.setNotification(
        id: noteId,
        title: data['title'],
        content: data['content'],
        time: data['reminderDateTime'],
        frequency: data['frequency'],
      );
    }
    if (data['lable'].isNotEmpty) {
      ref.read(lablesprovider.notifier).addLableforNotes(noteId, data['lable']);
    }
    state = [newCard, ...state];
    return noteId;
  }

  Future<void> pin(List<int> select) async {
    final topin = select.toSet();
    final list = state
        .where((note) => topin.contains(note['id'] as int))
        .map((note) => note['Pinned'] as int)
        .toSet();

    int value = 0;
    if (list.length > 1) {
      value = 1;
    } else {
      value = list.first == 0 ? 1 : 0;
    }
    final List<Future<void>> pinTasks = [];
    for (final note in state) {
      if (topin.contains(note['id'] as int)) {
        pinTasks.add(db.updatePin(note['id'], value));
      }
    }
    try {
      await Future.wait(pinTasks);
    } catch (e) {
      print('Error during concurrent note deletion: $e');
    }
    state = state.map((note) {
      if (topin.contains(note['id'] as int)) {
        return {...note, "Pinned": value};
      }
      return note;
    }).toList();
  }

  Future<void> delete(List<int> select) async {
    final idsToDelete = select.toSet();
    final List<Future<void>> deletionTasks = [];
    for (final note in state) {
      if (idsToDelete.contains(note['id'] as int)) {
        final fileName = note['Imagefile'] as String?;
        final noteId = note['id'] as int;
        if (fileName != null) {
          ref.read(imageCacheProvider.notifier).remove(noteId);
          notify.cancelNotification(noteId);
          deletionTasks.add(db.deleteImageFile(fileName));
        }
        deletionTasks.add(db.deleteNote(noteId));
      }
    }
    try {
      await Future.wait(deletionTasks);
    } catch (e) {
      print('Error during concurrent note deletion: $e');
    }
    state = state
        .where((note) => !idsToDelete.contains(note['id'] as int))
        .toList();
  }

  Future<void> update(Map data) async {
    final imgfile = data['img'].isNotEmpty ? "img_${data['id']}.json" : '';
    final index = state.indexWhere((note) => note['id'] == data['id']);
    if (index == -1) return;

    if (data['img'].isNotEmpty) {
      final List<String> image = data['img']
          .map<String>((item) => base64Encode(item))
          .toList();
      db.writeimg(image, imgfile);
    } else if (index != -1 && state[index]['Imagefile'] != '') {
      db.deleteImageFile(state[index]['Imagefile']);
    }

    await db.updateNote(
      data['id']!,
      data['title'],
      data['content'],
      imgfile,
      data['pinned'],
      data['reminder'],
      data['reminder'] == 1 ? data['reminderDateTime'] : null,
      data['frequency'],
    );
    if (data['reminder'] == 1 && data['reminderDateTime'] != null) {
      notify.setNotification(
        id: data['id'],
        title: data['title'],
        content: data['content'],
        time: data['reminderDateTime'],
        frequency: data['frequency'],
      );
    } else {
      notify.cancelNotification(data['id']);
    }
    if (data['img'].isNotEmpty) {
      ref.read(imageCacheProvider.notifier).update(data['id'], data['img']);
    } else {
      ref.read(imageCacheProvider.notifier).remove(data['id']);
    }
    if (data['lable'].isNotEmpty) {
      ref
          .read(lablesprovider.notifier)
          .addLableforNotes(data['id'], data['lable']);
    }
    final imgFuture = Future.value(data['img']);
    final date = DateTime.now().toIso8601String();
    final updatedCard = {
      "Title": data['title'],
      "id": data['id'],
      "Description": data['content'],
      "images": imgFuture,
      "Imagefile": imgfile,
      'Created_Date': date,
      'Modified_Date': date,
      'Pinned': data['pinned'] ?? 0,
      'Reminder': data['reminder'] ?? 0,
      'Frequency': data['frequency'] ?? 'Once',
      "ReminderDateTime":
          data['reminder'] == 1 && data['reminderDateTime'] != null
          ? (data['reminderDateTime'] as tz.TZDateTime).toIso8601String()
          : null,
    };
    final newState = [...state];
    newState[index] = updatedCard;
    state = newState;
  }

  Map<String, dynamic>? fetch(int? id) {
    return state.firstWhere((note) => note['id'] == id);
  }

  Future<void> disableReminder(int id) async {
    Map<String, dynamic>? note;
    try {
      note = state.firstWhere((n) => n['id'] == id);
    } catch (_) {
      note = await db.getNotes(id);
      if (note.isNotEmpty) {
        state = [...state, note];
      }
    }
    if (note.isNotEmpty &&
        (note['Frequency'] == 'Once' || note['Frequency'] == null)) {
      await db.updateReminder(id, 0, null, 'Once');
      state = state.map((n) {
        if (n['id'] == id) {
          return {
            ...n,
            'Reminder': 0,
            'ReminderDateTime': null,
            'Frequency': 'Once',
          };
        }
        return n;
      }).toList();
    }
  }

  Future<List<Map<String, dynamic>>> getNotesforLable(int lableId) async {
    return await db.getNotesforLable(lableId);
  }
}

class LablesNotifier extends Notifier<List<Map<String, dynamic>>> {
  final db = SqfliteProvider.instance;
  @override
  build() {
    return [];
  }

  Future<void> fetchfromstorage() async {
    state = [...await db.getallLables()];
  }

  Future<void> add(String lable) async {
    final lableId = await db.insertLable(lable);
    print("lableId.....$lableId");
    state = [
      ...state,
      {'id': lableId, 'Lable': lable},
    ];
  }

  Future<void> update(int lableId, String lable) async {
    await db.updateLable(lableId, lable);
    state = state.map((l) {
      if (l['id'] == lableId) {
        return {...l, 'Lable': lable};
      }
      return l;
    }).toList();
  }

  Future<void> delete(int lableId) async {
    await db.deleteLable(lableId);
    state = state.where((l) => l['id'] != lableId).toList();
  }

  Future<List<Map<String, dynamic>>> getLablesforNotes(int noteId) async {
    return await db.getLablesforNotes(noteId);
  }

  Future<void> addLableforNotes(
    int noteId,
    List<Map<String, dynamic>> lables,
  ) async {
    await db.addLableforNotes(noteId, lables);
  }
}

class ImageNotifier extends Notifier<ImageCache> {
  @override
  ImageCache build() {
    return {};
  }

  void update(int noteId, decodedImages) {
    print(
      "updated cache for noteId $noteId.... ${decodedImages.length} images",
    );
    state = {...state, noteId: decodedImages};
  }

  void remove(int noteId) {
    final newState = Map<int, List<Uint8List>>.from(state);
    newState.remove(noteId);
    print("removed cache for noteId $noteId.... ${newState.length} images");
    state = newState;
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationDetails notificationDetails;
  bool _initialized = false;
  Future<void> initializeNotification() async {
    if (_initialized) {
      return;
    }

    const AndroidInitializationSettings androidInt =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSetting = InitializationSettings(
      android: androidInt,
    );
    await notificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (response) async {
        launchNotificationId = response.id;
        final navigator = navigatorKey.currentState;
        container.read(noteprovider.notifier).disableReminder(response.id!);
        if (navigator != null) {
          await navigator.push(
            MaterialPageRoute(
              builder: (context) => Notespage(type: "exist", idx: response.id),
            ),
          );
          launchNotificationId = null;
        }
      },
    );
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    final exactalarm = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (exactalarm != null) {
      await exactalarm.requestExactAlarmsPermission();
    }

    _updateNotificationDetails();
    _initialized = true;
  }

  void _updateNotificationDetails() {
    const visibility = NotificationVisibility.public;
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          importance: Importance.max,
          priority: Priority.high,
          channelShowBadge: true,
          showWhen: true,
          sound: null,
          fullScreenIntent: false,
          playSound: true,
          category: AndroidNotificationCategory.alarm,
          visibility: visibility,
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          subText: "Reminder",
          ticker: "Reminder",
          number: 1,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          autoCancel: true,
          ongoing: true,
        );
    notificationDetails = NotificationDetails(android: androidDetails);
  }

  Future<void> setNotification({
    required int id,
    required String title,
    required String content,
    required tz.TZDateTime time,
    String? frequency,
  }) async {
    await initializeNotification();

    DateTimeComponents? dtComponent;
    if (frequency == 'Daily') {
      dtComponent = DateTimeComponents.time;
    } else if (frequency == 'Weekly') {
      dtComponent = DateTimeComponents.dayOfWeekAndTime;
    } else if (frequency == 'Monthly') {
      dtComponent = DateTimeComponents.dayOfMonthAndTime;
    } else if (frequency == 'Yearly') {
      dtComponent = DateTimeComponents.dateAndTime;
    }

    await notificationsPlugin.cancel(id);
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      content,
      time,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: dtComponent,
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getAllNotification() async {
    return await notificationsPlugin.pendingNotificationRequests();
  }
}

class BatteryPermissionHandler {
  static Future<void> secureExactTimings(BuildContext context) async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    final prefs = await SharedPreferences.getInstance();
    bool alreadyAsked = prefs.getBool('battery_permission_asked') ?? false;
    if (status.isGranted || alreadyAsked) {
      return;
    }
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ensure On-Time Reminders"),
        content: const Text(
          "To prevent your reminders from being delayed by the system, "
          "please allow the app to run in the background.\n\n"
          "On the next screen, please select 'Allow'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("LATER"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("PROCEED"),
          ),
        ],
      ),
    );

    if (proceed == true) {
      await prefs.setBool('battery_permission_asked', true);
      final result = await Permission.ignoreBatteryOptimizations.request();
      if (!result.isGranted) {
        await openAppSettings();
      }
    }
  }
}

// class ShareNote {
//   final key = secretKey;
//   void shareNote(List<Map> data) async {
//     final json = jsonEncode(data);
//     final algorithm = AesGcm.with256bits();
//     final secretKey = secretKey(key);
//     final secretBox = await algorithm.encryptString(json, secretKey: secretKey);
//     final concatenatedBytes = secretBox.concatenation();
//     final base64String = base64Encode(concatenatedBytes);

//   }
// }
