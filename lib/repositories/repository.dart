import 'package:sqflite/sqflite.dart';
import 'package:coquetel_em_maos/repositories/dbConnection.dart';

class Repository {
  dbConnection _databaseConnection;

  Repository(){
    //Initialize db Connection
    _databaseConnection = dbConnection();
  }

  static Database  _database;

  Future<Database> get database async{
    if(_database!=null) return _database;
    _database = await _databaseConnection.SetDatabase();
    return _database;
  }

  insertData(table, data) async{
    var con = await database;
    return await con.insert(table, data);
  }

  readData(table) async{
    var con = await database;
    return await con.query(table);
  }

  readDataById(table, categoryId) async{
    var con = await database;
    return await con.query(table, where: "id=?", whereArgs: [categoryId]);
  }

  updateData(table, data) async{
    var con = await database;
    return await con.update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  deleteData(table, categoryId) async{
    var con = await database;
    return await con.rawDelete("DELETE FROM $table WHERE id = $categoryId");
  }
}