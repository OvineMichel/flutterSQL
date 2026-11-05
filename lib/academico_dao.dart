import 'package:dbestudante/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class Estudante {
  final int? id;
  final String nome;
  final String matricula;
  const Estudante({this.id, required this.nome, required this.matricula});
  factory Estudante.fromMap(Map<String, Object?> map) => Estudante(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        matricula: map['matricula'] as String,
      );
  Map<String, Object?> toMap() => {'id': id, 'nome': nome, 'matricula': matricula};
}

class Disciplina {
  final int? id;
  final String nome;
  final String codigo;
  const Disciplina({this.id, required this.nome, required this.codigo});
  factory Disciplina.fromMap(Map<String, Object?> map) => Disciplina(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        codigo: map['codigo'] as String,
      );
  Map<String, Object?> toMap() => {'id': id, 'nome': nome, 'codigo': codigo};
}

class Cursando {
  final int estudanteId;
  final int disciplinaId;
  final String estudanteNome;
  final String matricula;
  final String disciplinaNome;
  final String codigo;
  const Cursando({
    required this.estudanteId,
    required this.disciplinaId,
    required this.estudanteNome,
    required this.matricula,
    required this.disciplinaNome,
    required this.codigo,
  });
  factory Cursando.fromMap(Map<String, Object?> map) => Cursando(
        estudanteId: map['estudante_id'] as int,
        disciplinaId: map['disciplina_id'] as int,
        estudanteNome: map['estudante_nome'] as String,
        matricula: map['matricula'] as String,
        disciplinaNome: map['disciplina_nome'] as String,
        codigo: map['codigo'] as String,
      );
}

class AcademicoDao {
  final Databasehelper _helper = Databasehelper();

  Future<List<Estudante>> listarEstudantes() async {
    final db = await _helper.database;
    final rows = await db.query('estudante', orderBy: 'nome COLLATE NOCASE');
    return rows.map(Estudante.fromMap).toList();
  }
  Future<void> salvarEstudante(Estudante item) async {
    final db = await _helper.database;
    if (item.id == null) {
      await db.insert('estudante', {'nome': item.nome, 'matricula': item.matricula}, conflictAlgorithm: ConflictAlgorithm.abort);
    } else {
      await db.update('estudante', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    }
  }
  Future<void> excluirEstudante(int id) async {
    final db = await _helper.database;
    await db.delete('estudante', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Disciplina>> listarDisciplinas() async {
    final db = await _helper.database;
    final rows = await db.query('disciplina', orderBy: 'nome COLLATE NOCASE');
    return rows.map(Disciplina.fromMap).toList();
  }
  Future<void> salvarDisciplina(Disciplina item) async {
    final db = await _helper.database;
    if (item.id == null) {
      await db.insert('disciplina', {'nome': item.nome, 'codigo': item.codigo}, conflictAlgorithm: ConflictAlgorithm.abort);
    } else {
      await db.update('disciplina', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    }
  }
  Future<void> excluirDisciplina(int id) async {
    final db = await _helper.database;
    await db.delete('disciplina', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Cursando>> listarCursando() async {
    final db = await _helper.database;
    final rows = await db.rawQuery('''
      SELECT c.estudante_id, c.disciplina_id,
             e.nome AS estudante_nome, e.matricula,
             d.nome AS disciplina_nome, d.codigo
      FROM cursando c
      INNER JOIN estudante e ON e.id = c.estudante_id
      INNER JOIN disciplina d ON d.id = c.disciplina_id
      ORDER BY e.nome COLLATE NOCASE, d.nome COLLATE NOCASE
    ''');
    return rows.map(Cursando.fromMap).toList();
  }
  Future<void> matricular(int estudanteId, int disciplinaId) async {
    final db = await _helper.database;
    await db.insert('cursando', {'estudante_id': estudanteId, 'disciplina_id': disciplinaId}, conflictAlgorithm: ConflictAlgorithm.abort);
  }
  Future<void> atualizarMatricula(int antigoEstudanteId, int antigaDisciplinaId, int novoEstudanteId, int novaDisciplinaId) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      await txn.delete('cursando', where: 'estudante_id = ? AND disciplina_id = ?', whereArgs: [antigoEstudanteId, antigaDisciplinaId]);
      await txn.insert('cursando', {'estudante_id': novoEstudanteId, 'disciplina_id': novaDisciplinaId}, conflictAlgorithm: ConflictAlgorithm.abort);
    });
  }
  Future<void> cancelarMatricula(int estudanteId, int disciplinaId) async {
    final db = await _helper.database;
    await db.delete('cursando', where: 'estudante_id = ? AND disciplina_id = ?', whereArgs: [estudanteId, disciplinaId]);
  }
}
