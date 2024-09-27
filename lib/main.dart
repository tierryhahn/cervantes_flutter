import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'helpers/db_helper.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Cervantes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleInsert(BuildContext context) async {
    final text = _textController.text;
    final number = int.tryParse(_numberController.text);

    if (text.isNotEmpty && number != null && number > 0) {
      try {
        await dbHelper.insertCadastro(text, number);
        _showMessage(context, 'Registrado com sucesso');
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          _showMessage(context, 'Erro: O número já está cadastrado.');
        } else {
          _showMessage(context, 'Erro ao registrar: ${e.toString()}');
        }
      }
    } else {
      _showMessage(context, 'Por favor, insira valores válidos');
    }
  }

  Future<void> _searchCadastroForEditing(BuildContext context) async {
    final number = int.tryParse(_numberController.text);

    if (number != null && number > 0) {
      final cadastro = await dbHelper.getCadastroByNumero(number);
      if (cadastro != null) {
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
                _showMessage(context, 'Cadastro atualizado com sucesso');
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        _showMessage(context, 'Nenhum cadastro encontrado com esse número');
      }
    } else {
      _showMessage(context, 'Por favor, insira um número válido');
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final number = int.tryParse(_numberController.text);

    if (number != null && number > 0) {
      final result = await dbHelper.deleteCadastro(number);
      if (result > 0) {
        _showMessage(context, 'Deletado com sucesso');
      } else {
        _showMessage(context, 'Nenhum cadastro encontrado para deletar');
      }
    } else {
      _showMessage(context, 'Por favor, insira um número válido');
    }
  }

  void _clearForm() {
    _textController.clear();
    _numberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste Cervantes'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
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
                    Text(
                      'Teste Cervantes',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300.0,
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300.0,
                      child: TextField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          labelText: 'Número',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleInsert(context),
                              child: Text('Enviar'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _searchCadastroForEditing(context),
                              child: Text('Editar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 300.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleDelete(context),
                              child: Text('Deletar'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _clearForm,
                              child: Text('Limpar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditScreen extends StatelessWidget {
  final Map<String, dynamic> cadastro;
  final Function(Map<String, dynamic>) onSave;

  final _textController = TextEditingController();
  final _numberController = TextEditingController();

  EditScreen({
    required this.cadastro,
    required this.onSave,
  }) {
    _textController.text = cadastro['texto'];
    _numberController.text = cadastro['numero'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cadastro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
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
                    Container(
                      width: 300.0,
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300.0,
                      child: TextField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          labelText: 'Número',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final updatedCadastro = {
                          'id': cadastro['id'],
                          'texto': _textController.text,
                          'numero': int.tryParse(_numberController.text) ?? cadastro['numero'],
                        };
                        onSave(updatedCadastro);
                      },
                      child: Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}