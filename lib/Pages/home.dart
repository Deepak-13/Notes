
import 'package:notes/Components/custom_appbar.dart';
import 'package:notes/Components/custom_card.dart';
import 'package:notes/Components/side_menu.dart';
import 'package:notes/Pages/notes.dart';
import 'package:notes/Pages/reminderList.dart';
import 'package:notes/Pages/settings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Provider/comman.dart';


class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  List card=[];
  List<int> selected=[];
  bool _selectionMode =false;
  int _view = 2;
  List<Map<String, dynamic>> filteredlist=[];
  @override
  void initState() {
    super.initState();
    if (NotificationService.launchNotificationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final int id = NotificationService.launchNotificationId!;
        await ref.read(noteprovider.notifier).disableReminder(id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Notespage(type: "exist", idx: id)));
        NotificationService.launchNotificationId = null;
      });
    }
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
      ref.read(noteprovider.notifier).delete(selected);
    }
    if(txt=="pin"){
      ref.read(noteprovider.notifier).pin(selected);
    }
    setState(() {
      selected.clear();
      _selectionMode= selected.isNotEmpty;
    });
  }

  Future<void> openNotes(int idx) async {
        print(idx);
      await Navigator.push(context, MaterialPageRoute(builder: (context)=>Notespage(type: "exist",idx:idx)));
  }

  Future<void> openSettings() async {
    Navigator.pop(context);
    Navigator.push(context,MaterialPageRoute(builder: (context)=>Settings()));
  }

  Future<void> openNotification() async {
    Navigator.pop(context);
    Navigator.push(context,MaterialPageRoute(builder: (context)=>ReminderList()));
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(filteredListProvider);
    final misc=ref.watch(dataprovider);
    _view = misc['view'];
    final pinned = list.where((c) => c['Pinned'] == 1).toList();
    final others = list.where((c) => c['Pinned'] == 0).toList();
    return Scaffold(
      drawer: SideMenu(settings: openSettings,notification: openNotification),
      appBar: CustomAppbar(mode: _selectionMode, count: selected.length.toString(), close: closeselection),
      body:
      list.isEmpty?
        Center(
          child: Text("No Notes Available",style: TextStyle(fontSize: 18))
        )
      :
      CustomScrollView(
        slivers: [
            if(pinned.isNotEmpty)...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("PINNED", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: _view,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  itemBuilder: (context, index) => 
                  CustomCard(
                    cardData: pinned[index],
                    isSelected: selected.contains(pinned[index]["id"]), 
                    isSelectionMode: _selectionMode, 
                    onSelect: select,
                    tap: openNotes,
                  ),
                  childCount: pinned.length,
                ),
              ),
            ],
            if(others.isNotEmpty)...[
              if(pinned.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("OTHERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: _view,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  itemBuilder: (context, index) => 
                  CustomCard(
                    cardData: others[index],
                    isSelected: selected.contains(others[index]["id"]), 
                    isSelectionMode: _selectionMode, 
                    onSelect: select,
                    tap: openNotes,
                  ),
                  childCount: others.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        onPressed:() async {
          await Navigator.push(context,MaterialPageRoute(builder: (context)=>const Notespage(type:"new",idx:0)));
        },
        tooltip: 'add notes',
        child: const Icon(Icons.add),
      ), 
    );
  }
}

