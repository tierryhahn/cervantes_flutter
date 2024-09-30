import 'package:flutter/material.dart';
import 'package:flutter_sqlite_test/features/edit/edit_screen.dart';
import 'package:flutter_sqlite_test/helpers/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cadastros = [];

  @override
  void initState() {
    super.initState();
    _loadCadastros();
  }

  // Método para carregar todos os cadastros do banco de dados
  Future<void> _loadCadastros() async {
    final allCadastros = await dbHelper.getAllCadastros();
    setState(() {
      cadastros = allCadastros;
    });
  }

  // Método para exibir uma mensagem usando o ScaffoldMessenger
  void message({required String message}) {
    return _showMessage(context, message);
  }

  // Método privado para exibir uma mensagem usando o ScaffoldMessenger
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Método para lidar com a inserção de um novo cadastro
  Future<void> _handleInsert(BuildContext context) async {
    final text = _nameController.text;
    final number = int.tryParse(_numberController.text);
    if (text.isNotEmpty && number != null && number > 0) {
      try {
        await dbHelper.insertCadastro(text, number);
        message(message: 'Registrado com sucesso');
        _clearForm();
        _loadCadastros();
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          message(message: 'Erro: O número já está cadastrado.');
        } else {
          message(message: 'Erro ao registrar: ${e.toString()}');
        }
      }
    } else {
      message(message: 'Por favor, insira valores válidos');
    }
  }

  // Método para buscar um cadastro pelo número e abrir a tela de edição
  Future<void> _searchCadastroForEditing(BuildContext context) async {
    final number = int.tryParse(_numberController.text);

    if (number != null && number > 0) {
      final cadastro = await dbHelper.getCadastroByNumero(number);
      if (cadastro != null) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditScreen(
                cadastro: cadastro,
                onSave: (updatedCadastro) async {
                  await dbHelper.updateCadastro(
                    updatedCadastro['id'],
                    updatedCadastro['texto'],
                    updatedCadastro['numero'],
                  );
                  message(message: 'Cadastro atualizado com sucesso');
                  _loadCadastros();
                  if (context.mounted) Navigator.pop(context);
                },
                dbHelper: dbHelper,
              ),
            ),
          );
        }
      } else {
        message(message: 'Nenhum cadastro encontrado com esse número');
      }
    } else {
      message(message: 'Por favor, insira um número válido');
    }
  }

  // Método para deletar um cadastro pelo número
  Future<void> _handleDelete(BuildContext context) async {
    final number = int.tryParse(_numberController.text);

    if (number != null && number > 0) {
      final result = await dbHelper.deleteCadastro(number);
      if (result > 0) {
        message(message: 'Deletado com sucesso');
        _loadCadastros();
      } else {
        message(message: 'Nenhum cadastro encontrado para deletar');
      }
    } else {
      message(message: 'Por favor, insira um número válido');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _numberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Cervantes'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: cardRegister,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: cardTable,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o card de registro, contendo o formulário de cadastro
  Card get cardRegister => Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cardRegisterTitle,
              const SizedBox(height: 20),
              SizedBox(
                width: 300.0,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300.0,
                child: TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleInsert(context),
                        child: const Text('Enviar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _searchCadastroForEditing(context),
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleDelete(context),
                        child: const Text('Deletar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearForm,
                        child: const Text('Limpar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // Título do card de registro
  Text get cardRegisterTitle => const Text(
        'Teste Cervantes',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      );

  // Widget para o card da tabela, exibindo os cadastros carregados
  Card get cardTable => Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Cadastros',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200.0,
                child: SingleChildScrollView(
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(150.0),
                    border: TableBorder.all(
                      color: Colors.black,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    children: [
                      const TableRow(children: [
                        Column(children: [
                          Text('Nome', style: TextStyle(fontSize: 18.0))
                        ]),
                        Column(children: [
                          Text('Número', style: TextStyle(fontSize: 18.0))
                        ]),
                      ]),
                      // Gera uma linha para cada cadastro
                      for (var cadastro in cadastros)
                        TableRow(children: [
                          Column(children: [Text(cadastro['texto'])]),
                          Column(
                              children: [Text(cadastro['numero'].toString())]),
                        ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}