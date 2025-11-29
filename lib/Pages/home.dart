import 'package:app_v1/Components/custom_appbar.dart';
import 'package:app_v1/Components/custom_card.dart';
import 'package:app_v1/Pages/notes.dart';
import 'package:app_v1/Provider/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  List? card=[];
  List selected=[];
  bool _selectionMode =false;
  int _view = 2;
  List<Map<String, dynamic>> filteredlist=[];
  
  @override
  void initState() {
    super.initState();
  }

  void select(int idx){
      setState(() {
          if(selected.contains(idx)){
              selected.removeWhere((item)=>item==idx);
          }
          else{
            selected.add(idx);
          }
           _selectionMode= _selectionMode==false? selected.isNotEmpty : true;
      });
  }
  void closeselection(String txt) {
    if(txt=="delete")
    {
      ref.read(note.notifier).delete(selected);
    }
    setState(() {
      selected.clear();
      _selectionMode= selected.isNotEmpty;
    });
  }

  Future<void> openNotes(int idx) async {
      await Navigator.push(context, MaterialPageRoute(builder: (context)=>Notespage(type: "exist",idx:idx)));
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(filteredListProvider);
    final misc=ref.watch(data);
    _view = misc['view'];
    card=list;
    return Scaffold(
      appBar: CustomAppbar(mode: _selectionMode, count: selected.length.toString(), close: closeselection),
      body:
       Center(
        child: GridView.builder(
          padding: EdgeInsets.all(5),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _view,
            childAspectRatio: _view == 1 ? 2.0 : 1.0,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4
            ), 
          itemCount: card?.length,
          itemBuilder: (BuildContext context,int index){
            return CustomCard(cardData: card?[index], isSelected: selected.contains(card?[index]["id"]), isSelectionMode: _selectionMode, onSelect: select,tap: openNotes);
          })
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        onPressed:() async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (context)=>const Notespage(type:"new")));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}

