# Teste Cervantes

Este projeto é um exemplo de aplicação Flutter integrada com um banco de dados SQLite local utilizando a biblioteca `sqflite_common_ffi`. A aplicação permite cadastrar, editar e deletar registros com um número único.

## Requisitos

- Flutter SDK
- Dart SDK

## Clonando o Repositório

Primeiramente, clone o repositório para sua máquina local:

```sh
git clone https://github.com/seu_usuario/seu_repositorio.git
cd seu_repositorio
```

## Instalando as Dependências

Para instalar as dependências do projeto, rode o comando abaixo na raiz do projeto:

```sh
flutter pub get
```

## Configurando e Rodando o Projeto no Windows

Como esta aplicação utiliza a biblioteca `sqflite_common_ffi`, ela pode ser executada em um ambiente desktop como o Windows. Siga os passos abaixo para testar o projeto no Windows:

1. **Inicializar o Projeto:**

   Para inicializar e testar o projeto em um ambiente Windows, execute o seguinte comando:

   ```sh
   flutter run -d windows
   ```

## Descrição dos Arquivos Principais

### db_helper.dart

Este arquivo contém a classe `DatabaseHelper`, que é responsável por gerenciar o banco de dados SQLite. Aqui estão os métodos principais:

- `getAllCadastros()`: Retorna todos os registros da tabela `cadastro`.
- `insertCadastro(String texto, int numero)`: Insere um registro na tabela `cadastro`.
- `updateCadastro(int id, String texto, int numero)`: Atualiza um registro existente na tabela `cadastro`.
- `deleteCadastro(int numero)`: Deleta um registro da tabela `cadastro` com base no número fornecido.
- `getCadastroByNumero(int numero)`: Obtém um registro da tabela `cadastro` com base no número fornecido.

Além disso, a classe define triggers para logar operações de inserção, atualização e deleção na tabela `log_operacoes`.

### main.dart

Este arquivo contém a configuração principal do Flutter e define a estrutura da UI. A tela principal possui campos de texto para inserção do nome e número, e botões para enviar, editar, deletar e limpar os dados.

- `MyApp`: A raiz da aplicação.
- `MyHomePage`: A tela principal que contém os campos de formulário e botões.
- `EditScreen`: Uma tela separada para editar registros existentes. Leva o cadastro a ser editado e uma função de callback para salvar as mudanças.
