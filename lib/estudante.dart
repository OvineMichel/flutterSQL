class Estudante {
  int? id;
  String nome;
  String matricula;
  Estudante({this.id, required this.nome, required this.matricula});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "matricula": matricula,
    };
  }

  factory Estudante.fromMap(Map<String, dynamic> map) {
    return Estudante(
      id: map['id'],
      nome: map['nome'],
      matricula: map['matricula'],
    );
  }
}
