import 'package:dbestudante/academico_dao.dart';
import 'package:flutter/material.dart';

class PaginaAcademica extends StatefulWidget {
  const PaginaAcademica({super.key});
  @override
  State<PaginaAcademica> createState() => _PaginaAcademicaState();
}

class _PaginaAcademicaState extends State<PaginaAcademica> {
  final _dao = AcademicoDao();
  final _nome = TextEditingController();
  final _identificador = TextEditingController();
  List<Estudante> _estudantes = [];
  List<Disciplina> _disciplinas = [];
  List<Cursando> _cursando = [];
  int _aba = 0;
  int? _editId;
  int? _estudanteSelecionado;
  int? _disciplinaSelecionada;
  Cursando? _cursandoEditando;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  @override
  void dispose() {
    _nome.dispose();
    _identificador.dispose();
    super.dispose();
  }

  Future<void> _atualizar() async {
    try {
      final estudantes = await _dao.listarEstudantes();
      final disciplinas = await _dao.listarDisciplinas();
      final cursando = await _dao.listarCursando();
      if (!mounted) return;
      setState(() {
        _estudantes = estudantes;
        _disciplinas = disciplinas;
        _cursando = cursando;
        _carregando = false;
        if (_estudanteSelecionado != null && !estudantes.any((e) => e.id == _estudanteSelecionado)) _estudanteSelecionado = null;
        if (_disciplinaSelecionada != null && !disciplinas.any((d) => d.id == _disciplinaSelecionada)) _disciplinaSelecionada = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      _mensagem('Não foi possível carregar os dados: $e');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _limparFormulario() {
    _nome.clear();
    _identificador.clear();
    setState(() => _editId = null);
  }

  Future<void> _salvarEntidade() async {
    final nome = _nome.text.trim();
    final identificador = _identificador.text.trim();
    if (nome.isEmpty || identificador.isEmpty) {
      _mensagem('Preencha todos os campos.');
      return;
    }
    final estavaEditando = _editId != null;
    try {
      if (_aba == 0) {
        await _dao.salvarEstudante(Estudante(id: _editId, nome: nome, matricula: identificador));
      } else {
        await _dao.salvarDisciplina(Disciplina(id: _editId, nome: nome, codigo: identificador));
      }
      _limparFormulario();
      await _atualizar();
      _mensagem(estavaEditando ? 'Registro atualizado.' : 'Registro cadastrado.');
    } catch (e) {
      _mensagem('Não foi possível salvar. Verifique se matrícula/código já existe.');
    }
  }

  Future<void> _excluir(int id, String entidade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir $entidade?'),
        content: const Text('A ação não poderá ser desfeita. Relações associadas também serão removidas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;
    if (entidade == 'estudante') await _dao.excluirEstudante(id);
    if (entidade == 'disciplina') await _dao.excluirDisciplina(id);
    await _atualizar();
  }

  Future<void> _salvarCursando() async {
    if (_estudanteSelecionado == null || _disciplinaSelecionada == null) {
      _mensagem('Selecione um estudante e uma disciplina.');
      return;
    }
    try {
      if (_cursandoEditando == null) {
        await _dao.matricular(_estudanteSelecionado!, _disciplinaSelecionada!);
      } else {
        await _dao.atualizarMatricula(
          _cursandoEditando!.estudanteId,
          _cursandoEditando!.disciplinaId,
          _estudanteSelecionado!,
          _disciplinaSelecionada!,
        );
      }
      setState(() => _cursandoEditando = null);
      await _atualizar();
      _mensagem('Matrícula em disciplina salva.');
    } catch (_) {
      _mensagem('Essa relação já existe ou não pôde ser salva.');
    }
  }

  Widget _formularioEntidade() {
    final estudante = _aba == 0;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_editId == null ? 'Novo ${estudante ? 'estudante' : 'disciplina'}' : 'Editar ${estudante ? 'estudante' : 'disciplina'}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(controller: _nome, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: estudante ? 'Nome completo' : 'Nome da disciplina', prefixIcon: const Icon(Icons.edit_outlined), border: const OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _identificador, decoration: InputDecoration(labelText: estudante ? 'Matrícula' : 'Código', prefixIcon: const Icon(Icons.tag), border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: _salvarEntidade, icon: Icon(_editId == null ? Icons.add : Icons.save_outlined), label: Text(_editId == null ? 'Cadastrar' : 'Salvar alterações'))),
            if (_editId != null) ...[const SizedBox(width: 8), IconButton(tooltip: 'Cancelar edição', onPressed: _limparFormulario, icon: const Icon(Icons.close))],
          ]),
        ]),
      ),
    );
  }

  Widget _listaEntidades() {
    final estudante = _aba == 0;
    if (_carregando) return const Center(child: CircularProgressIndicator());
    final count = estudante ? _estudantes.length : _disciplinas.length;
    if (count == 0) return _vazio(estudante ? 'Nenhum estudante cadastrado' : 'Nenhuma disciplina cadastrada', 'Use o formulário acima para adicionar o primeiro registro.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: count,
      itemBuilder: (context, index) {
        final nome = estudante ? _estudantes[index].nome : _disciplinas[index].nome;
        final detalhe = estudante ? 'Matrícula: ${_estudantes[index].matricula}' : 'Código: ${_disciplinas[index].codigo}';
        final id = estudante ? _estudantes[index].id! : _disciplinas[index].id!;
        return Card(child: ListTile(
          leading: CircleAvatar(child: Icon(estudante ? Icons.person_outline : Icons.menu_book_outlined)),
          title: Text(nome), subtitle: Text(detalhe),
          onTap: () => setState(() {
            _editId = id;
            _nome.text = nome;
            _identificador.text = estudante ? _estudantes[index].matricula : _disciplinas[index].codigo;
          }),
          trailing: IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: () => _excluir(id, estudante ? 'estudante' : 'disciplina')),
        ));
      },
    );
  }

  Widget _telaCursando() {
    return Column(children: [
      Card(margin: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(_cursandoEditando == null ? 'Matricular em disciplina' : 'Editar matrícula', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(value: _estudanteSelecionado, isExpanded: true, decoration: const InputDecoration(labelText: 'Estudante', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)), items: _estudantes.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.nome} — ${e.matricula}', overflow: TextOverflow.ellipsis))).toList(), onChanged: (value) => setState(() => _estudanteSelecionado = value)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(value: _disciplinaSelecionada, isExpanded: true, decoration: const InputDecoration(labelText: 'Disciplina', border: OutlineInputBorder(), prefixIcon: Icon(Icons.menu_book_outlined)), items: _disciplinas.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.nome} — ${d.codigo}', overflow: TextOverflow.ellipsis))).toList(), onChanged: (value) => setState(() => _disciplinaSelecionada = value)),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: _estudantes.isEmpty || _disciplinas.isEmpty ? null : _salvarCursando, icon: const Icon(Icons.link), label: Text(_cursandoEditando == null ? 'Vincular' : 'Salvar relação'))), if (_cursandoEditando != null) IconButton(onPressed: () => setState(() { _cursandoEditando = null; _estudanteSelecionado = null; _disciplinaSelecionada = null; }), icon: const Icon(Icons.close))]),
        if (_estudantes.isEmpty || _disciplinas.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Cadastre pelo menos um estudante e uma disciplina antes de criar a relação.')),
      ]))),
      Expanded(child: _carregando ? const Center(child: CircularProgressIndicator()) : _cursando.isEmpty ? _vazio('Nenhuma matrícula vinculada', 'As relações entre estudante e disciplina aparecerão aqui.') : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), itemCount: _cursando.length, itemBuilder: (context, index) {
        final item = _cursando[index];
        return Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.hub_outlined)),
          title: Text(item.estudanteNome),
          subtitle: Text('${item.matricula}\n${item.disciplinaNome} · ${item.codigo}'), isThreeLine: true,
          onTap: () => setState(() { _cursandoEditando = item; _estudanteSelecionado = item.estudanteId; _disciplinaSelecionada = item.disciplinaId; }),
          trailing: IconButton(tooltip: 'Remover vínculo', icon: const Icon(Icons.link_off), onPressed: () async { await _dao.cancelarMatricula(item.estudanteId, item.disciplinaId); await _atualizar(); }),
        ));
      })),
    ]);
  }

  Widget _vazio(String titulo, String descricao) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_outlined, size: 42, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 10), Text(titulo, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(descricao, textAlign: TextAlign.center)])));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão Acadêmica'), centerTitle: false),
      body: IndexedStack(index: _aba, children: [
        Column(children: [_formularioEntidade(), Expanded(child: _listaEntidades())]),
        Column(children: [_formularioEntidade(), Expanded(child: _listaEntidades())]),
        _telaCursando(),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex: _aba, onDestinationSelected: (index) { _limparFormulario(); setState(() => _aba = index); }, destinations: const [
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Estudantes'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Disciplinas'),
        NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub), label: 'Cursando'),
      ]),
    );
  }
}
