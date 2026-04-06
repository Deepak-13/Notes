import 'dart:typed_data';
import 'package:notes/Components/camera.dart';
import 'package:notes/Components/dateTimeSheet.dart';
import 'package:notes/Components/imgdisplay.dart';
import 'package:notes/Components/lableSheet.dart';
import 'package:notes/Pages/home.dart' as home;
import 'package:notes/Services/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:timezone/timezone.dart' as tz;

class Notespage extends ConsumerStatefulWidget {
  final String type;
  final int? idx;
  const Notespage({super.key, required this.type, this.idx});

  @override
  ConsumerState<Notespage> createState() => _NotespageState();
}

class _NotespageState extends ConsumerState<Notespage> {
  late final TextEditingController titlecontroller;
  late final TextEditingController contentcontroller;
  late List<Uint8List> _capturedImageList = [];
  final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  late String _orginalTitle = '';
  late String _orginalContent = '';
  tz.TZDateTime? reminderDateTime;
  tz.TZDateTime? _orginalreminderDateTime;
  late List<Uint8List> _orginalImg = [];
  String reminderFrequency = "Once";
  String _orginalReminderFrequency = "Once";
  String heroTag = 'notes_new';
  int pinned = 0;
  int reminder = 0;
  bool _isNewNote = false;
  int? _currentId;
  int _orginalPin = 0;
  int _orginalReminder = 0;
  List SelectedLable = [];
  Future<void> addimg(XFile img) async {
    isDialOpen.value = false;
    final Uint8List bytes = await img.readAsBytes();
    setState(() {
      _capturedImageList.add(bytes);
    });
  }

  void deleteimg(int id) {
    setState(() {
      _capturedImageList.removeAt(id);
    });
  }

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.type == "new";
    _currentId = widget.idx;
    heroTag = _isNewNote ? 'notes_new' : 'notes_$_currentId';
    titlecontroller = TextEditingController();
    contentcontroller = TextEditingController();
    if (!_isNewNote) {
      final card = ref.read(noteprovider.notifier).fetch(_currentId);
      if (card != null) {
        titlecontroller.text = card["Title"] ?? '';
        contentcontroller.text = card["Description"] ?? '';
        pinned = card['Pinned'];
        reminder = card['Reminder'];
        reminderFrequency = card['Frequency'] ?? "Once";

        _orginalPin = pinned;
        _orginalReminder = reminder;
        _orginalReminderFrequency = reminderFrequency;

        _orginalTitle = titlecontroller.text;
        _orginalContent = contentcontroller.text;
        if (card['ReminderDateTime'] != null) {
          DateTime? dt = DateTime.parse(card['ReminderDateTime']);
          reminderDateTime = tz.TZDateTime.from(dt, tz.local);
          _orginalreminderDateTime = tz.TZDateTime.from(dt, tz.local);
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNewNote && _capturedImageList.isEmpty) {
      final provider = noteImagesProvider((noteId: _currentId!, limit: null));
      final imageFuture = ref.read(provider.future);
      Future.microtask(() async {
        final List<Uint8List> images = await imageFuture;
        if (mounted) {
          setState(() {
            _orginalImg = images;
            _capturedImageList = List<Uint8List>.from(images);
          });
        }
      });
    }
  }

  bool allowsave() {
    final currentTitle = titlecontroller.text.trim();
    final currentContent = contentcontroller.text.trim();

    final textChanged =
        currentTitle != _orginalTitle || currentContent != _orginalContent;

    final imageCountChanged = _capturedImageList.length != _orginalImg.length;
    final pinchanged = pinned != _orginalPin;
    final reminderchanged = reminder != _orginalReminder;
    final datetimechanged =
        reminder == 1 && reminderDateTime != _orginalreminderDateTime;
    final frequencyChanged =
        reminder == 1 && reminderFrequency != _orginalReminderFrequency;
    bool imageContentChanged = false;
    if (!imageCountChanged && _capturedImageList.isNotEmpty) {
      for (int i = 0; i < _capturedImageList.length; i++) {
        if (_capturedImageList[i] != _orginalImg[i]) {
          imageContentChanged = true;
          break;
        }
      }
    }
    return textChanged ||
        imageCountChanged ||
        imageContentChanged ||
        pinchanged ||
        reminderchanged ||
        datetimechanged ||
        frequencyChanged;
  }

  void pin() {
    setState(() {
      pinned = pinned == 0 ? 1 : 0;
    });
  }

  void setReminder(int active, tz.TZDateTime datetime, String frequency) {
    if (active != 2) {
      setState(() {
        reminder = active;
        if (active == 1) {
          reminderDateTime = datetime;
          reminderFrequency = frequency;
        } else {
          reminderDateTime = null;
          reminderFrequency = "Once";
        }
      });
    }
  }

  Future<int> update() async {
    int id = 0;
    final title = titlecontroller.text.trim();
    final content = contentcontroller.text.trim();
    if (_isNewNote) {
      if (title.isNotEmpty ||
          content.isNotEmpty ||
          _capturedImageList.isNotEmpty) {
        var data = {
          "title": title,
          "content": content,
          "img": _capturedImageList,
          "pinned": pinned,
          'reminder': reminder,
          'frequency': reminderFrequency,
          "reminderDateTime": (reminder == 1 && reminderDateTime != null)
              ? tz.TZDateTime.from(reminderDateTime!, tz.local)
              : null,
          "lable": SelectedLable,
        };
        id = await ref.read(noteprovider.notifier).add(data);
        if (mounted) {
          setState(() {
            _currentId = id;
            _isNewNote = false;
            heroTag = 'notes_$id';
          });
        }
        return id;
      }
    } else {
      if (allowsave()) {
        if (title.isNotEmpty ||
            content.isNotEmpty ||
            _capturedImageList.isNotEmpty) {
          var data = {
            "id": _currentId,
            "title": title,
            "content": content,
            "img": _capturedImageList,
            "pinned": pinned,
            "reminder": reminder,
            "frequency": reminderFrequency,
            "reminderDateTime": (reminder == 1 && reminderDateTime != null)
                ? tz.TZDateTime.from(reminderDateTime!, tz.local)
                : null,
            "lable": SelectedLable,
          };
          ref.read(noteprovider.notifier).update(data);
          Future.microtask(() {
            ref.invalidate(noteImagesProvider((noteId: id, limit: null)));
            ref.invalidate(noteImagesProvider((noteId: id, limit: 3)));
          });
        } else {
          ref.read(noteprovider.notifier).delete([?_currentId]);
          Future.microtask(() {
            ref.invalidate(noteImagesProvider((noteId: id, limit: null)));
            ref.invalidate(noteImagesProvider((noteId: id, limit: 3)));
          });
        }
      }
    }
    return _currentId ?? 0;
  }

  @override
  void dispose() {
    titlecontroller.dispose();
    contentcontroller.dispose();
    isDialOpen.dispose();
    super.dispose();
  }

  Future<void> openlablemodal(BuildContext context, notesId) async {
    isDialOpen.value = false;
    final result = await showDialog<List>(
      context: context,
      builder: (BuildContext context) {
        return LableSheet(notesId: notesId ?? 0);
      },
    );
    if (result != null) {
      SelectedLable = result.map((item) => item['id']).toList();
    }
  }

  Future<void> openmodal(BuildContext context) async {
    isDialOpen.value = false;
    await BatteryPermissionHandler.secureExactTimings(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Datetimesheet(
          setreminder: setReminder,
          reminder: reminder,
          reminderDateTime: reminderDateTime != null
              ? tz.TZDateTime.from(reminderDateTime!, tz.local)
              : null,
          frequency: reminderFrequency,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await update();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await update();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => home.MyHomePage()),
                );
              }
            },
          ),
          actions: [
            IconButton(
              iconSize: 30,
              icon: Icon(
                pinned == 1 ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              tooltip: 'Pin',
              onPressed: () => pin(),
            ),
            IconButton(
              iconSize: 30,
              icon: Icon(
                reminder == 1 ? Icons.add_alert : Icons.add_alert_outlined,
              ),
              tooltip: 'Reminder',
              onPressed: () => openmodal(context),
            ),
            IconButton(
              iconSize: 30,
              icon: Icon(Icons.label_outline),
              tooltip: 'Lable',
              onPressed: () => openlablemodal(context, _currentId),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_capturedImageList.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: Imgdisplay(
                    img: _capturedImageList,
                    ondelete: deleteimg,
                    idx: _currentId ?? -1,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w800,
                        ),
                        controller: titlecontroller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(100),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          controller: contentcontroller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: "Start typing...",
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(100),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reminder == 1)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 24.0,
                    bottom: 24.0,
                    top: 12.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => openmodal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat(
                                    "MMM dd, hh:mm a",
                                  ).format(reminderDateTime!.toLocal()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                if (reminderFrequency != "Once")
                                  Text(
                                    reminderFrequency,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(180),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: SpeedDial(
          openCloseDial: isDialOpen,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(size: 28.0),
          visible: true,
          curve: Curves.bounceInOut,
          renderOverlay: false,
          switchLabelPosition: false,
          direction: SpeedDialDirection.right,
          children: [
            SpeedDialChild(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Camera(type: "camera", getimg: addimg),
            ),
            SpeedDialChild(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Camera(type: "gallery", getimg: addimg),
            ),
          ],
        ),
      ),
    );
  }
}
