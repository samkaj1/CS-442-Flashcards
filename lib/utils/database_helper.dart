import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper { //initial helper class 
  static const String _databaseName = 'decks.db'; // db name
  static const int _databaseVersion = 1; // db version
  bool exists = false; //existence flag

  DatabaseHelper._();
  static final DatabaseHelper _singleton = DatabaseHelper._(); 
  factory DatabaseHelper() => _singleton; 
  Database? _database; //reference to DB
  get db async {  //getter for DB
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {  //DB initialization function
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    print(dbPath); // ignore: avoid_print
    var db = await openDatabase(dbPath, //open db
        version: _databaseVersion,


        onCreate: (Database db, int version) async {         // called when db created

      await db.execute(''' 
          CREATE TABLE decks(
            id INTEGER PRIMARY KEY,
            title TEXT
          )
        '''); // create the decks table

     
      await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY,
            question TEXT,
            answer TEXT,
            decksId  INTEGER,
            FOREIGN KEY (decksId) REFERENCES decks(id)
          )
        ''');  // create the cards table
    });
    return db;
  }

  Future<bool> checkIfDBExists() async { //method to check db existence
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    return await databaseExists(dbPath);
  }

  Future<List<Map<String, dynamic>>> query(String table, //fetch records from table with opt where clause
      {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table) : db.query(table, where: where);
  }


  Future<int> insert(String table, Map<String, dynamic> data) async {   // insert record into table
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }


  Future<void> update(String table, Map<String, dynamic> data) async {   // update record in table
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }


  Future<void> deleteFlashCardByDeckId(String table, int deckId) async {   // delete flashcards in table by deck ID
    final db = await this.db;
    await db.delete(
      table,
      where: 'decksId = ?',
      whereArgs: [deckId],
    );
  }
  
    Future<void> delete(String table, int id) async { //delete record from table
    final db = await this.db;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<int, int>> getCardsAmount() async { //get # of cards for each deck from DB
    final db = await this.db;
    var result = await db.rawQuery(
        "SELECT decksId, COUNT(id) as cardAmount FROM cards GROUP BY decksId");
    Map<int, int> countsMap = {
      for (var e in result) e['decksId']: e['cardAmount']
    };
    return countsMap;
  }
}
