import 'package:dbestudante/DatabaseHelper.dart';
import 'package:dbestudante/estudante.dart';
import 'package:sqflite/sqflite.dart';

class EstudanteDao {
  final Databasehelper _dbHelper = Databasehelper();

  //Incluir no banco
  Future<void> incluirEstudante(Estudante e) async {
    final db = await _dbHelper.database;
    await db.insert(
      "estudante",
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Editar no banco
  Future<void> editarEstudante(Estudante e) async {
    final db = await _dbHelper.database;
    await db.update(
      "estudante",
      e.toMap(),
      where: "id = ?",
      whereArgs: [e.id],
    );
  }

  //excluir
  Future<void> deleteEstudante(int index) async {
    final db = await _dbHelper.database;
    await db.delete(
      "estudante",
      where: "id = ?",
      whereArgs: [index],
    );
  }

  Future<List<Estudante>> listarEstudantes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query("estudante");
    return List.generate(maps.length, (index) {
      return Estudante.fromMap(maps[index]);
    });
  }
}
