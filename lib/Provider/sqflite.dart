import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class SqfliteProvider {

  SqfliteProvider._privateConstructor();
  static final SqfliteProvider instance = SqfliteProvider._privateConstructor();

  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'my_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Notes_table(id INTEGER PRIMARY KEY AUTOINCREMENT, Title TEXT, Description TEXT,Imagefile TEXT,Created_Date TEXT,Modified_Date TEXT,Pinned INTEGER DEFAULT 0)',
        );
        
        await db.execute(
          '''CREATE TABLE Settings_table(id INTEGER PRIMARY KEY CHECK (id = 1), view INTEGER DEFAULT 2, theme TEXT DEFAULT 'Default')''',
        );
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      }
    );

    return _database!;
  }

  Future<Map<String, Object?>> getSettings() async{
    final db = await database;
    final List<Map<String, Object?>> settings = await db.query('Settings_table');
      if (settings.isNotEmpty) {
        return settings.first;
      }
      return {
        'id': 1,
        'view': 2,
        'theme': 'Default',
      };
  }

  Future updatesettings(int? view,String? theme) async{
      final db=await database;
      Map<String, dynamic> values = {};
      if (view != null) values['view'] = view;
      if (theme != null) values['theme'] = theme;

      if (values.isEmpty) return;
      int count = await db.update(
        'Settings_table',
        values,
        where: 'id = ?',
        whereArgs: [1],
      );

      if (count == 0) {
        values['id'] = 1;
        values.putIfAbsent('view', () => 2);
        values.putIfAbsent('theme', () => 'Default');
        
        await db.insert('Settings_table', values);
      }
  }

  Future<List<Map<String, dynamic>>> getallNotes() async {
  final db = await database;
  final notes = await db.query('Notes_table');
  final data = notes.toList();

    final List<Future<Map<String, dynamic>>> notesFutures = data.map((note) async {
    final imgfile = note['Imagefile'] as String;
    final List<dynamic> datafromfile = await readImage(imgfile); 
    final List<Uint8List> decodedBytesList = datafromfile.map((item) {
      return base64Decode(item);
    }).toList();
    final Future<List<Uint8List>> cachedFuture = Future.value(decodedBytesList);
    return {...note, 'images': cachedFuture};
  }).toList();
  final List<Map<String, dynamic>> result = await Future.wait(notesFutures);
  return result;
}

   Future<Map<String, dynamic>> getNotes(int id) async {
    final db = await database;
    final notes = await db.query(
      'Notes_table',
      where: 'id = ?',
      whereArgs: [id],
    );
    final result = {...notes.first};
    return result;
   }


  Future<int> insertNote(String title, String description, String imagefile,int pinned) async {
    final db = await database;
    final Id = await db.transaction((txn) async {
    final date = DateTime.now().toIso8601String();
      final noteId = await txn.insert(
        'Notes_table',
        {
          'Title': title,
          'Description': description,
          'Imagefile': imagefile,
          'Created_Date':date,
          'Modified_Date':date,
          'Pinned':pinned
        },
       
      );
      return noteId;
    });
    return Id;
  }
    
   Future<void> deleteNote(int id) async {
      final db = await database;
      await db.delete(
        'Notes_table',
        where: 'id = ?',
        whereArgs: [id],
      );
   }

   Future<void> updateNote(int id, String title, String description,String imagefile,int pinned) async {
      final db = await database;
      final date = DateTime.now().toIso8601String();
      await db.update(
        'Notes_table',
        {
          'Title': title,
          'Description': description,
          'Imagefile': imagefile,
          'Modified_Date':date,
          'Pinned':pinned
        },
        where: 'id = ?',
        whereArgs: [id],
      );
   }
   Future<void> updatePin(int id,int pin) async{
      final db = await database;
      await db.update(
        'Notes_table',
        {
          'Pinned':pin
        },
        where: 'id = ?',
        whereArgs: [id],
      );
   }

   Future<void> updateImgFile(int id, String imagefile) async {
      final db = await database;
      await db.update(
        'Notes_table',
        {
          'Imagefile': imagefile,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
   }

    Future<File> writeimg(List<String> data,String filename) async {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final imageFile = File('$path/$filename');
        final jsonfile=jsonEncode(data);
        return imageFile.writeAsString(jsonfile);
    }

    Future<List<dynamic>> readImage(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');
      final data=await file.readAsString();
      return jsonDecode(data).toList();
    } catch (e) {
       print("img fetching failed $filename $e....",);
      return [];
    }
  }


   Future<void> deleteImageFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      return;
    }
  }
}