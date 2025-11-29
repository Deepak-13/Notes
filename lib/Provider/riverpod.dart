import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_v1/Provider/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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



class NotesNotifier extends Notifier<List<Map<String, dynamic>>>{

    final store = Storage();
    final filename ="img_";
    @override
    build() {
        fetchfromstorage();
        return [];
    }
    
    Future<void> fetchfromstorage() async {
      state = await store.read();
    }
  

   void add(String title,String content,List<Uint8List> img) {
        int maxId = state.isEmpty ? 0 : state.map((card) => card['id'] as int).reduce((value, element) => max(value, element));
        int newId = maxId + 1;
        String name="$filename$newId";
        if(img.isNotEmpty){
          final data=img.map((item)=>base64Encode(item)).toList();
          store.writeimg(data, name);
        }

        final newCard = {"title": title, "id": newId,"content":content,"imgfile":img.isNotEmpty?name:''};
        state = [...state, newCard];
        store.write(state);
    }

    Future<void> delete(List select) async {
       final idsToDelete = select.toSet();
       for (var card in state) {
        int cardId = card['id'] as int;
        if (idsToDelete.contains(cardId)) {
          String filename = card['imgfile'] as String;
          if (filename.isNotEmpty) {
            await store.deleteImageFile(filename); 
          }
        }
      }
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

    Future<List<Uint8List>> fetchimg(int? id) async {
      final items =state.firstWhere((card) => card['id'] == id);
      final List<String> datafromfile = await store.readImage(filename);
      final List<Uint8List> decodedBytesList = datafromfile.map((item){
        return base64Decode(item);
      }).toList();
      return decodedBytesList;
    }
}