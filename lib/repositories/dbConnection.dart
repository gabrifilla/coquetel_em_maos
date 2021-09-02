import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class dbConnection{
  SetDatabase() async{
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, "db_crud_learn");
    var database = await openDatabase(path, version: 1, onCreate: _onCreatingDatabase);
    return database;
  }
  _onCreatingDatabase(Database database, int version) async{
    await database.execute("CREATE TABLE categoria(id INTEGER PRIMARY KEY autoincrement, nome TEXT, descricao TEXT, dropdownInfo INTEGER)");
    await database.execute("CREATE TABLE dropdownInfos(id INTEGER PRIMARY KEY autoincrement, descricaoDD TEXT");
    await database.rawInsert("INSERT INTO dropdownInfos VALUES ('Nome')");
    await database.rawInsert("INSERT INTO dropdownInfos VALUES ('Sobrenome')");
    await database.rawInsert("INSERT INTO dropdownInfos VALUES ('Escritura')");
    await database.rawInsert("INSERT INTO dropdownInfos VALUES ('Teste')");
  }
}