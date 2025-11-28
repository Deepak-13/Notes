import 'package:app_v1/Components/camera.dart';
import 'package:app_v1/Provider/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    @override
    void initState() {
      super.initState();
      titlecontroller = TextEditingController();
      contentcontroller = TextEditingController();

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
      if (title.isNotEmpty || content.isNotEmpty) {
        widget.type=="new"? ref.read(note.notifier).add(title, content) : ref.read(note.notifier).update(widget.idx,title, content); 
      }
      return true;
    }

    @override
    void dispose() { 
        // update();
        titlecontroller.dispose();
        contentcontroller.dispose();
        _listener.dispose();
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
      )
        );
    }
}