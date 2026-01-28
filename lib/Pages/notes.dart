import 'dart:math';
import 'dart:typed_data';
import 'package:app_v1/Components/camera.dart';
import 'package:app_v1/Components/imgdisplay.dart';
import 'package:app_v1/Provider/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

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
    late List<Uint8List> _orginalImg = [];
    String heroTag='notes_new';
    int pinned =0;
    bool _isNewNote=false;
    int? _currentId;
    int _orginalPin=0;
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
          _orginalPin = pinned;
          _orginalTitle = titlecontroller.text;
          _orginalContent = contentcontroller.text;
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
      bool imageContentChanged = false;
      if (!imageCountChanged && _capturedImageList.isNotEmpty) {
        for (int i = 0; i < _capturedImageList.length; i++) {
          if (_capturedImageList[i] != _orginalImg[i]) {
            imageContentChanged = true;
            break;
          }
        }
      }
      return textChanged || imageCountChanged || imageContentChanged || pinchanged;
    }

    void pin(){
      setState(() {
          pinned=pinned==0?1:0;
      });
    }

    Future<int> update()
    async { 
      int id =0;
      final title = titlecontroller.text.trim();
      final content = contentcontroller.text.trim();
      if (_isNewNote) {
        if (title.isNotEmpty || content.isNotEmpty || _capturedImageList.isNotEmpty){
            var data ={"title":title,"content":content,"img":_capturedImageList,"pinned":pinned};
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
            var data ={"id":_currentId,"title":title,"content":content,"img":_capturedImageList,"pinned":pinned};
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
          title: Text("Note",style: TextStyle()),
          actions: [
            IconButton(
                  iconSize: 30,
                  icon: Icon(pinned==1?Icons.push_pin:Icons.push_pin_outlined),
                  tooltip: 'Pin',
                  onPressed: () => pin(),
                ),
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