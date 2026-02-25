import 'dart:typed_data';
import 'package:notes/Components/camera.dart';
import 'package:notes/Components/dateTimeSheet.dart';
import 'package:notes/Components/imgdisplay.dart';
import 'package:notes/Provider/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:timezone/timezone.dart' as tz;

class Notespage extends ConsumerStatefulWidget{
  final String type;
  final int? idx;
  const Notespage({super.key,required this.type,this.idx});

  @override
  ConsumerState<Notespage> createState() => _NotespageState();
}

class _NotespageState extends ConsumerState<Notespage>{
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
    String heroTag='notes_new';
    int pinned =0;
    int reminder =0;
    bool _isNewNote=false;
    int? _currentId;
    int _orginalPin=0;
    int _orginalReminder=0;
    Future<void> addimg(XFile img) async {
        isDialOpen.value=false;
        final Uint8List bytes= await img.readAsBytes();
        setState(() {
          _capturedImageList.add(bytes);
        });
    }

    void deleteimg(int id){
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
      if(!_isNewNote){
        final card=ref.read(noteprovider.notifier).fetch(_currentId);
        if(card !=null)
        {
          titlecontroller.text=card["Title"]?? '';
          contentcontroller.text=card["Description"]?? '';
          pinned=card['Pinned'];
          reminder=card['Reminder'];
          reminderFrequency = card['Frequency'] ?? "Once";
         
          _orginalPin = pinned;
          _orginalReminder = reminder;
          _orginalReminderFrequency = reminderFrequency;
          
          _orginalTitle = titlecontroller.text;
          _orginalContent = contentcontroller.text;
          print(card['ReminderDateTime']);
          if(card['ReminderDateTime']!=null)
          {
            DateTime? dt = DateTime.parse(card['ReminderDateTime']);
            reminderDateTime= tz.TZDateTime.from(dt, tz.local);
            _orginalreminderDateTime= tz.TZDateTime.from(dt, tz.local);
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

    bool allowsave(){
      final currentTitle = titlecontroller.text.trim();
      final currentContent = contentcontroller.text.trim();
      
      final textChanged = currentTitle != _orginalTitle || currentContent != _orginalContent;

      final imageCountChanged = _capturedImageList.length != _orginalImg.length;
      final pinchanged = pinned != _orginalPin;
      final reminderchanged = reminder != _orginalReminder;
      final datetimechanged = reminder==1 && reminderDateTime != _orginalreminderDateTime;
      final frequencyChanged = reminder==1 && reminderFrequency != _orginalReminderFrequency;
      bool imageContentChanged = false;
      if (!imageCountChanged && _capturedImageList.isNotEmpty) {
        for (int i = 0; i < _capturedImageList.length; i++) {
          if (_capturedImageList[i] != _orginalImg[i]) {
            imageContentChanged = true;
            break;
          }
        }
      }
      return textChanged || imageCountChanged || imageContentChanged || pinchanged || reminderchanged || datetimechanged || frequencyChanged;
    }

    void pin(){
      setState(() {
          pinned=pinned==0?1:0;
      });
    }

    void setReminder(int active,tz.TZDateTime datetime, String frequency) {
      if(active!=2)
      {
        setState(() {
          reminder=active;
          if(active==1)
          {
            reminderDateTime=datetime;
            reminderFrequency = frequency;
          }
          else{
            reminderDateTime=null;
            reminderFrequency = "Once";
          }
        });
      } 
    }

    Future<int> update()
    async { 
      int id =0;
      final title = titlecontroller.text.trim();
      final content = contentcontroller.text.trim();
      if (_isNewNote) {
        if (title.isNotEmpty || content.isNotEmpty || _capturedImageList.isNotEmpty){
            var data ={
              "title":title,
              "content":content,
              "img":_capturedImageList,
              "pinned":pinned,
              'reminder':reminder, 
              'frequency': reminderFrequency,
              "reminderDateTime": (reminder == 1 && reminderDateTime != null)? 
              tz.TZDateTime.from(reminderDateTime!, tz.local)
              : null};
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
      }
      else {
        if (allowsave()) {
          if(title.isNotEmpty || content.isNotEmpty || _capturedImageList.isNotEmpty)
          {
            var data ={
              "id":_currentId,
              "title":title,
              "content":content,
              "img":_capturedImageList,
              "pinned":pinned,
              "reminder":reminder,
              "frequency": reminderFrequency,
              "reminderDateTime": (reminder == 1 && reminderDateTime != null)? 
              tz.TZDateTime.from(reminderDateTime!, tz.local)
              : null
              };
            ref.read(noteprovider.notifier).update(data);
            Future.microtask(() {
              ref.invalidate(noteImagesProvider((noteId: id, limit: null)));
              ref.invalidate(noteImagesProvider((noteId: id, limit: 3)));
            });
          }
          else{
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
    Future<void> openmodal(BuildContext context) async {
      await BatteryPermissionHandler.secureExactTimings(context);
      showModalBottomSheet<void>(
              context: context,
              backgroundColor: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (BuildContext context) {
                return Datetimesheet(setreminder: setReminder, reminder: reminder,reminderDateTime: reminderDateTime!=null? tz.TZDateTime.from(reminderDateTime!, tz.local):null, frequency: reminderFrequency);
              },
            );
    }
    @override
    Widget build(BuildContext context){
     
      return PopScope(
        onPopInvokedWithResult:(didPop, result) async {
          if(didPop){
            await update();
          }
        },
        child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Notes",style: TextStyle()),
          actions: [
            IconButton(
                  iconSize: 30,
                  icon: Icon(pinned==1?Icons.push_pin:Icons.push_pin_outlined),
                  tooltip: 'Pin',
                  onPressed: () => pin(),
                ),
            IconButton(
        iconSize: 30,
        icon: Icon(reminder==1?Icons.add_alert:Icons.add_alert_outlined),
        tooltip: 'Reminder',
        onPressed: () => openmodal(context),
    )
          ],
        ),
        body: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(15),
          child: Center(
          child: Column(
            children: [
              if(_capturedImageList.isNotEmpty)
                SizedBox(
                    height: 200,
                    child: Imgdisplay(img: _capturedImageList,ondelete:deleteimg,idx: _currentId ?? -1),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child:Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child:  TextField(
                        style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w700),
                        controller: titlecontroller,
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w700),
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                      )
                      )
                    ),
                ],
              ),
              SizedBox(height: 5.0),
              Expanded(
                flex: 2,
                child:  Padding(
                padding: EdgeInsets.only(left: 10.0),
                child:  TextField(
                  style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500,),
                  controller: contentcontroller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Note",
                    hintStyle: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500,),
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
                )
              ),
              if(reminder==1)
              SafeArea(
                bottom: true,
                child:  Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openmodal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Text(
                                    DateFormat("dd MMMM hh:mm a").format(reminderDateTime!.toLocal()),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                ),
                                if (reminderFrequency != "Once")
                                    Text(
                                        reminderFrequency, // Show frequency if not Once
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                                        ),
                                    ),
                            ],
                        ),
                      ],
                    ),
                ))))
            ]
          ),
        ),
        ),    
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: SpeedDial(
              openCloseDial:isDialOpen,
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: const IconThemeData(size: 28.0),
              visible: true,
              curve: Curves. bounceInOut,
              renderOverlay:false,
              switchLabelPosition :false,
              direction:SpeedDialDirection.right,
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
                )
              ],
            ),
      ));
    }
    
      
}