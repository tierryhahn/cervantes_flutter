import 'package:flutter/material.dart';
import 'package:flutter_sqlite_test/helpers/db_helper.dart';

class EditScreen extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final Map<String, dynamic> cadastro;
  final Function(Map<String, dynamic>) onSave;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  // Construtor da classe EditScreen
  EditScreen({
    super.key,
    required this.cadastro,
    required this.onSave,
    required this.dbHelper,
  }) {
    // Inicializa os controladores de texto com os valores do cadastro fornecido
    _nameController.text = cadastro['texto'];
    _numberController.text = cadastro['numero'].toString();
  }

  // Método para verificar duplicidade e salvar o cadastro atualizado
  Future<void> _checkDuplicateAndSave(BuildContext context) async {
    final newNumber = int.tryParse(_numberController.text) ?? cadastro['numero'];
    
    // Verifica se o número foi alterado e se já existe no banco de dados
    if (cadastro['numero'] != newNumber) {
      final duplicate = await dbHelper.getCadastroByNumero(newNumber);
      if (duplicate != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: O número $newNumber já está cadastrado.')),
        );
        return;
      }
    }

    // Cria um mapa com os dados atualizados do cadastro
    final updatedCadastro = {
      'id': cadastro['id'],
      'texto': _nameController.text,
      'numero': newNumber,
    };

    // Chama a função de callback para salvar o cadastro atualizado
    onSave(updatedCadastro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cadastro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: cardEdit(context),
          ),
        ),
      ),
    );
  }

  // Widget para o card de edição, contendo o formulário de edição
  Card cardEdit(BuildContext context) {
    return Card(
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
            ElevatedButton(
              onPressed: () => _checkDuplicateAndSave(context),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}