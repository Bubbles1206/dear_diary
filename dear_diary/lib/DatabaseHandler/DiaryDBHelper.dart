import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/DiaryModel.dart';

class DiaryDbHelper {
  static Database _db;

  static const String DB_Name = 'diaryStorage.db';
  static const String Table_User = 'Diary';
  static const int Version = 1;

  static const String C_UserName = 'user_name';
  static const String C_Date = 'date';
  static const String C_Text = 'text';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserName TEXT,"
        " $C_Text TEXT,"
        " $C_Date TEXT"
        ")");
  }

  Future<int> saveData(DiaryModel diaryModel) async {
    var dbClient = await db;
    var res = await dbClient.insert(Table_User, diaryModel.toMap());
    return res;
  }

  Future<int> saveDiary(DiaryModel dModel) async {
    String uname = dModel.username;
    String text = dModel.text;
    String date = dModel.date;
    var dbClient = await db;
    var res = await dbClient.rawInsert(
        'INSERT INTO $Table_User(user_name, text, date) VALUES(?, ?, ?)',
        [uname, text, date]);
    return res;
  }

  Future<List<DiaryModel>> getDiaries(String username) async {
    var dbClient = await db;
    List<DiaryModel> finalDiaries = [];
    var diaries = (await dbClient.rawQuery(
        "SELECT * FROM $Table_User WHERE " "$C_UserName = '$username'"));
    if (diaries.isNotEmpty) {
      diaries.forEach((element) {
        String uname = element.values.elementAt(0);
        String text = element.values.elementAt(1);
        String date = element.values.elementAt(2);
        // print(element.keys);
        // print(element.values);
        // print("username: " + uname);
        // print("text    : " + text);
        // print("date    : " + date);
        DiaryModel testData = new DiaryModel(uname, text, date);
        finalDiaries.add(testData);
      });
      return finalDiaries;
    }
    return null;
  }
}
