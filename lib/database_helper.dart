import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  //Singleton
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();
  static final String tableLocations = 'locations';
  static final String columnId = 'id';
  static final String columnTitle = 'title';

  Database? myDB;

  //DB Open (path ->if exists else create db)
  ///All Queries  ....

  Future<Database> getDb() async {
    myDB ??= await openDb();
    return myDB!;
    //Longer CODE VERSION OF ABOVE
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDb();
    //   return myDB!;
    // }
  }

  Future<Database> openDb() async {
    //Unsafe -> Directory appDirectory = await getApplicationCacheDirectory();
    Directory appDirectory = await getApplicationDocumentsDirectory();

    String dbPath = join(appDirectory.path, 'locationsDB.db');
    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        //create tables
        db.execute(
          //  'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, desc TEXT)',
          'CREATE TABLE $tableLocations ($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT)',
        );

        // //create more tables if needed
        //  db.execute(
        //    'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, desc TEXT)', );
        //      db.execute(
        //    'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, desc TEXT)', );
        //      db.execute(
        //    'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, desc TEXT)', );
      },
      version: 1,
    );
  }

  Future<bool> addLocation({required String mTitle}) async {
    final db = await getDb();
    int lastInsertId = await db.insert(tableLocations, {columnTitle: mTitle});
    return lastInsertId > 0;
  }

  //Raw Query + querry example

  Future<List<Map<String, dynamic>>> getLocationsRawQuery({
    required int id,
  }) async {
    final db = await getDb();
    return db.rawQuery('SELECT * FROM $tableLocations WHERE $columnId = ?', [
      id,
    ]);
  }

  Future<String> getDefaultLocation({required int id}) async {
    final db = await getDb();
    List<Map<String, dynamic>> mData = await db.query(
      tableLocations,
      columns: [columnTitle],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return mData[0]['title'];
  }

  //Fetch All Notes Columns
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await getDb();
    return db.query(tableLocations);
  }

  //Fetch Specific  Notes Columns
  Future<List<Map<String, dynamic>>> getLocationsSpecificCols() async {
    final db = await getDb();
    List<Map<String, dynamic>> mData = await db.query(
      tableLocations,
      columns: [columnId, columnTitle],
      //where:  '$columnId > 0',
      orderBy: '$columnId DESC',
    );
    return mData;
  }

  Future<bool> deleteLocation(int id) async {
    final db = await getDb();
    final rowsEffected = await db.delete(
      tableLocations,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }

  Future<bool> updateLocation(String id, String title) async {
    final db = await getDb();
    int rowsEffected = await db.update(
      tableLocations,
      {columnTitle: title},
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }

  Future<void> emptyDb() async {
    final db = await getDb();
    await db.delete(tableLocations);
    await db.rawDelete("DELETE FROM sqlite_sequence WHERE name = ?", [
      tableLocations,
    ]);
  }
}
