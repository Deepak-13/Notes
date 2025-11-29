import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {

  Future<File> get _localFile async {
    final directory = await getDownloadsDirectory();
    final path = directory?.path;
    return File('$path/notes.txt');
  }

  Future<File> writeimg(List<String> data,String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imageFile = File('$path/$filename');
    final jsonfile=jsonEncode(data);
    return imageFile.writeAsString(jsonfile);
  }

  Future<List<String>> readImage(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');
      final data=await file.readAsString();
      return jsonDecode(data).toList();
    } catch (e) {
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