import 'dart:async';
import 'dart:io';

import 'package:notes/model/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseVersion = 1;

  static final table = 'note_table';

  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';
  String colDescription = 'description';

  // a database
  static Database? _database;

  // privateconstructor
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // asking for a database
  Future<Database?> get database async {
    if (_database != null) return _database;

    // create a database if one doesn't exist
    _database = await _initDatabase();
    return _database;
  }

  // function to return a database
  _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    return await openDatabase(
        path, version: _databaseVersion, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    db.execute(
        'CREATE TABLE $table('
            '$colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER, $colDescription TEXT)'
    );
  }


  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  Future <List<Note>> getNoteList() async{
    final List noteMapList = await queryAllRows();

    final List<Note> noteList = [];

    noteMapList.forEach((noteMap) {
      noteList.add(Note.fromMap(noteMap));
    });
    noteList.sort((noteA, noteB) => noteA.date!.compareTo(noteB.date!));
    return noteList;
  }


  Future<int> insert(Note note) async {
    Database? db = await instance.database;
    return await db!.insert(table, note.toMap());
  }

  Future<int> update(Note note) async {
    Database? db = await instance.database;
    return await db!.update(table, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$colId = ?', whereArgs: [id]);
  }


}