# Gestão Acadêmica (Flutter + SQLite)

Aplicativo Flutter baseado no projeto fornecido. Mantém o banco local `sqflite` e implementa operações CRUD para Estudante, Disciplina e Cursando.

## Funcionalidades

- **Estudantes:** cadastrar, listar, editar e excluir (nome e matrícula).
- **Disciplinas:** cadastrar, listar, editar e excluir (nome e código).
- **Cursando:** criar, listar, editar e remover vínculos entre estudante e disciplina.
- A listagem de **Cursando** executa `INNER JOIN` com Estudante e Disciplina para apresentar nomes, matrícula e código.
- SQLite cria as tabelas e chaves estrangeiras; atualização do esquema do banco `if.db` existente está versionada de 1 para 2.
- Matrícula/código são únicos; não é permitido criar duas vezes a mesma relação estudante-disciplina.

## Executar

Com o Flutter SDK instalado, na raiz do projeto:

```sh
flutter pub get
flutter run
```

A persistência é local no dispositivo. A implementação fornecida usa `sqflite` para plataformas nativas Android/iOS/macOS; a integração padrão de `sqflite` não habilita o banco SQLite na versão Web sem um adaptador compatível.
