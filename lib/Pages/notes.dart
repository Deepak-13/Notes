import 'dart:math';
import 'dart:typed_data';

import 'package:app_v1/Components/camera.dart';
import 'package:app_v1/Components/imgdisplay.dart';
import 'package:app_v1/Provider/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

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
    late AppLifecycleListener _listener;
    late List<Map<String,dynamic>> _capturedImageList = [];
    final ValueNotifier<bool> isDialOpen = ValueNotifier(false);

    Future<void> addimg(XFile img) async {
        isDialOpen.value=false;
        final Uint8List bytes= await img.readAsBytes();
        int maxId = _capturedImageList.isEmpty ? 0 : _capturedImageList.map((card) => card['id'] as int).reduce((value, element) => max(value, element));
        int newId = maxId + 1;
        setState(() {
          _capturedImageList.add({"id":newId,"img":bytes});
        });
    }

    void deleteimg(int id){
      setState(() {
           _capturedImageList.removeWhere((item)=>item['id']==id);
      });
    }

    Future<void> _loadImages() async {
      final List<Uint8List> fetchedBytesList = await ref.read(note.notifier).fetchimg(widget.idx);
      final List<Map<String, dynamic>> newImageList = fetchedBytesList.map((item) {
        int maxId = _capturedImageList.isEmpty ? 0 : _capturedImageList.map((card) => card['id'] as int).reduce(max);
        int newId = maxId + 1;
        return {"id": newId, "img": item};
      }).toList();
      
      setState(() {
        _capturedImageList = newImageList;
      });
    }
    @override
    void initState() {
      super.initState();
      titlecontroller = TextEditingController();
      contentcontroller = TextEditingController();
      if(widget.type!="new")
      {_loadImages(); }
      final card=ref.read(note.notifier).fetch(widget.idx);
      if(card !=null)
      {
        titlecontroller.text=card["title"]?? '';
        contentcontroller.text=card["content"]?? '';
      }

      _listener =AppLifecycleListener(
        onPause: () => update(),
      );
    }

    bool update()
    { 
      final title = titlecontroller.text.trim();
      final content = contentcontroller.text.trim();
      final List<Uint8List> imgonly=_capturedImageList.map((item)=>item['img'] as Uint8List ).toList();
      if (title.isNotEmpty || content.isNotEmpty) {
        widget.type=="new"? ref.read(note.notifier).add(title, content,imgonly) : ref.read(note.notifier).update(widget.idx,title, content); 
      }
      return true;
    }

    @override
    void dispose() { 
        // update();
        titlecontroller.dispose();
        contentcontroller.dispose();
        _listener.dispose();
        isDialOpen.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context){
      return PopScope(
        onPopInvokedWithResult:(didPop, result) {
          if(didPop){
            update();
          }
        },
        child: 
          Scaffold(
        appBar: AppBar(
          backgroundColor:Theme.of(context).colorScheme.inversePrimary,
          title: Text("Note"),
        ),
        body: Center(
          child: Column(
            children: [
              if(_capturedImageList.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 200,
                   child: Imgdisplay(img: _capturedImageList,ondelete:deleteimg),
                  )
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
              SizedBox(height: 8.0),
              Expanded(
                flex: 2,
                child:  Padding(
                padding: EdgeInsets.only(left: 10.0),
                child:  TextField(
                  style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),
                  controller: contentcontroller,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Note",
                    hintStyle: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500),
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
                )
              ),
            ]
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: SpeedDial(
              openCloseDial:isDialOpen,
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: const IconThemeData(size: 28.0),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              visible: true,
              curve: Curves. bounceInOut,
              renderOverlay:false,
              switchLabelPosition :false,
              direction:SpeedDialDirection.right,
              children: [ 
                SpeedDialChild(
                  child: Camera(type: "camera", getimg: addimg),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                SpeedDialChild(
                  child: Camera(type: "gallery", getimg: addimg),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              ],
            ),
      )
        );
    }
}