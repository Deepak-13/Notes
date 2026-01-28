import 'dart:convert';
import 'dart:typed_data';
import 'package:app_v1/Provider/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final  noteprovider = NotifierProvider<NotesNotifier, List<Map<String, dynamic>>>(NotesNotifier.new);
final  dataprovider = NotifierProvider<DataNotifier, Map<String, dynamic>>(DataNotifier.new);
typedef ImageCache = Map<int, List<Uint8List>>;
typedef NoteImageParams = ({int noteId, int? limit});
final imageCacheProvider = NotifierProvider<ImageNotifier,ImageCache>(ImageNotifier.new);

final initializationProvider = FutureProvider<void>((ref) async {
  await ref.read(noteprovider.notifier).fetchfromstorage();
  await ref.read(dataprovider.notifier).fetchsettings();
});

class ImageNotifier extends Notifier<ImageCache>{
  @override
  ImageCache build() {
    return {};
  }
  
  void update(int noteId,decodedImages){
  
     print("updated cache for noteId $noteId.... ${decodedImages.length} images");
      state = {...state,noteId:decodedImages};
     
  }

  void remove(int noteId) {
        final newState = Map<int, List<Uint8List>>.from(state);
        newState.remove(noteId);
        print("removed cache for noteId $noteId.... ${newState.length} images");
        state = newState;
    }
}

final noteImagesProvider = FutureProvider.family<List<Uint8List>, NoteImageParams>((ref, params) async {
  final noteId = params.noteId;
  final cache = ref.watch(imageCacheProvider);
  if (cache.containsKey(noteId)) {
    final List<Uint8List> cachedImages = cache[noteId]!;
    print("fetching images from cache for noteId $noteId.... ${cachedImages.length} images");
    return (params.limit != null && params.limit! < cachedImages.length) 
          ? cachedImages.sublist(0, params.limit) 
          : cachedImages;
  }
  else{
    print("fetching images from cache for noteId $noteId.... not found in cache");
    return [];
  }
});




class NotesNotifier extends Notifier<List<Map<String, dynamic>>>{

    final db=SqfliteProvider.instance;
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
        final List<Uint8List> decodedImages = datafromfile.map((item) => base64Decode(item)).toList();
        Future.microtask(() => 
          ref.read(imageCacheProvider.notifier).update(noteId, decodedImages)
        );
      }
    }
  

   Future<int> add(Map data) async {
        final noteId = await db.insertNote(data['title'], data['content'], '',data['pinned']);
         String name=data['img'].isNotEmpty?"img_$noteId.json":'';
       if(data['img'].isNotEmpty){
          final List<String> image=data['img'].map<String>((item)=>base64Encode(item)).toList();
          db.writeimg(image, name);
        }
        await db.updateImgFile(noteId, name);
        ref.read(imageCacheProvider.notifier).update(noteId,data['img']);
        final date = DateTime.now().toIso8601String();
        final newCard = {"Title": data['title'], "id": noteId,"Description":data['content'],"Imagefile":name, 'Created_Date':date,'Modified_Date':date,'Pinned':data['pinned']??0};
        state = [newCard,...state];
        return noteId;
    }
    Future<void> pin(List<int> select) async{
      final topin = select.toSet();
      final list = state
      .where((note) => topin.contains(note['id'] as int))
      .map((note) => note['Pinned'] as int)
      .toSet();

      int value =0;
      if(list.length>1)
      { 
        value=1;
      }
      else{
        value = list.first==0?1:0;
      }
      final List<Future<void>> pinTasks = [];
      for (final note in state) {
        if (topin.contains(note['id'] as int)) {
          pinTasks.add(db.updatePin(note['id'],value));
        }
      }
       try {
        await Future.wait(pinTasks);
      } catch (e) {
        print('Error during concurrent note deletion: $e');
      }
      state = state.map((note){
          if(topin.contains(note['id'] as int)){
              return {...note,"Pinned":value};
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
      state = state.where((note) => !idsToDelete.contains(note['id'] as int)).toList();
    }

    Future<void> update(Map data) async { 
        final imgfile=data['img'].isNotEmpty?"img_${data['id']}.json":'';
        final index = state.indexWhere((note) => note['id'] == data['id']);
        if (index == -1) return;

        if(data['img'].isNotEmpty){
          final List<String> image=data['img'].map<String>((item)=>base64Encode(item)).toList();
          db.writeimg(image, imgfile);
        }
        else if (index != -1 && state[index]['Imagefile'] != '') {
          db.deleteImageFile(state[index]['Imagefile']);
        }
        
        await db.updateNote(data['id']!, data['title'], data['content'], imgfile,data['pinned']);

        if(data['img'].isNotEmpty)
        {
          ref.read(imageCacheProvider.notifier).update(data['id'],data['img']);
        }
        else
        {
          ref.read(imageCacheProvider.notifier).remove(data['id']);
        }

        final imgFuture = Future.value(data['img']);
        final date = DateTime.now().toIso8601String();
        final updatedCard = {"Title": data['title'], "id": data['id'],"Description":data['content'],"images":imgFuture,"Imagefile":imgfile, 'Created_Date':date,'Modified_Date':date,'Pinned':data['pinned']??0};
        final newState = [...state];
        newState[index] = updatedCard;
        state = newState;
    }

    Map<String, dynamic>? fetch(int? id){
        return state.firstWhere((note) => note['id'] == id);
    }

}

class DataNotifier extends Notifier<Map<String, dynamic>>{
    final db=SqfliteProvider.instance;

    @override
    build() {
        return {"view":2,"txt":'','theme':'Default'};
    }

    void changeView(){
      final view = state["view"] == 1 ? 2 : 1;
      db.updatesettings(view, null);
      state = {...state, "view": view};
    }

    void search(String txt){
      state = {...state, "txt": txt};
      print(state);
    }

    void changetheme(String mode){
      db.updatesettings(null, mode);
        state = state = {...state, "theme": mode};
    }

    Future<void> fetchsettings() async {
      final settings = await db.getSettings();
      state= {"view":settings['view'],"txt":'','theme':settings['theme']};
    }
}


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



