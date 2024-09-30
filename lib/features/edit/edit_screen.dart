import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  final Map<String, dynamic> cadastro;
  final Function(Map<String, dynamic>) onSave;

  final _textController = TextEditingController();
  final _numberController = TextEditingController();

  EditScreen({
    super.key,
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
        title: const Text('Editar Cadastro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: cardEdit,
          ),
        ),
      ),
    );
  }

  Card get cardEdit {
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
                controller: _textController,
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
              onPressed: () {
                final updatedCadastro = {
                  'id': cadastro['id'],
                  'texto': _textController.text,
                  'numero': int.tryParse(_numberController.text) ??
                      cadastro['numero'],
                };
                onSave(updatedCadastro);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
