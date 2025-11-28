import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';


final  note= NotifierProvider<NotesNotifier, List<Map<String, dynamic>>>(NotesNotifier.new);
final  data= NotifierProvider<DataNotifier, Map<String, dynamic>>(DataNotifier.new);
final searchQueryProvider = NotifierProvider<SearchNotifier,String>(SearchNotifier.new);


class SearchNotifier extends Notifier<String>{
  @override
  String build() {
    return '';
  }
  
  void search(String txt){
    state =txt;
  }
}

final filteredListProvider = Provider<List<Map<String, dynamic>>>((ref) {

  final fullList = ref.watch(note); 
  final query = ref.watch(searchQueryProvider); 

  if (query.trim().isEmpty) {
    return fullList; 
  }

  final lowerCaseQuery = query.toLowerCase();

  return fullList.where((card) {
    final title = card['title']?.toString().toLowerCase() ?? '';
    final content = card['content']?.toString().toLowerCase() ?? '';
    return title.contains(lowerCaseQuery) || content.contains(lowerCaseQuery);
  }).toList();
});

class DataNotifier extends Notifier<Map<String, dynamic>>{

    @override
    build() {
        return {"view":2};
    }

    void changeView(){
      state = {...state, "view": state["view"] == 1 ? 2 : 1};
    }
}

class Storage {

  Future<File> get _localFile async {
    final directory = await getDownloadsDirectory();
    final path = directory?.path;
    return File('$path/notes.txt');
  }

  Future<File> writeimg(List<int> data,String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imageFile = File('$path/$filename');
    return imageFile.writeAsBytes(data);
  }

  Future<List<int>> readImage(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');
      return file.readAsBytes();
    } catch (e) {
      return [];
    }
  }

  Future<File> write(List<Map<String, dynamic>> data) async {
    final file = await _localFile;
    final jsonofdata = jsonEncode(data);
    return file.writeAsString(jsonofdata);
  }

  Future<List<Map<String, dynamic>>> read() async {
    try{
      final file = await _localFile;
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      final dynamicList = jsonDecode(contents) as List<dynamic>;
      return dynamicList.cast<Map<String, dynamic>>();
    }
    catch (e) {
      return [];
    }
  }


}

class NotesNotifier extends Notifier<List<Map<String, dynamic>>>{

    final store = Storage();
    @override
    build() {
        fetchfromstorage();
        return [];
    }
    
    Future<void> fetchfromstorage() async {
      state = await store.read();
    }
  

   void add(String title,String content) {
        int maxId = state.isEmpty ? 0 : state.map((card) => card['id'] as int).reduce((value, element) => max(value, element));
        int newId = maxId + 1;
        final newCard = {"title": title, "id": newId,"content":content};
        state = [...state, newCard];
        store.write(state);
    }

    void delete(List select) {
       final idsToDelete = select.toSet();
       state = state.where((card) => !idsToDelete.contains(card['id'])).toList();
       store.write(state);
    }

    void update(int? id,String title,String content)
    {
      state = state.map((card){
        if(card['id']==id){
          return {...card,"title":title,"content":content};
        }
        return card;
      }
      ).toList();
      store.write(state);
    }

    Map<String, dynamic>? fetch(int? id){
      try {
            return state.firstWhere((card) => card['id'] == id);
        } catch (e) {
            // Handle case where ID is not found
            return null;
        }
    }
}