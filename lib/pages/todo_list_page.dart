import 'package:flutter/material.dart';
import 'package:todo_list/repositories/todo_repositories.dart';

import '../models/todo.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepositories todoRepositories = TodoRepositories();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  Todo? pressedTodo;

  int? lenTodos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepositories.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            pressedTodo = null;
          });
        },
        child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  "Lista de Tarefas",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: todoController,
                            decoration: InputDecoration(
                                errorText: errorText,
                                border: OutlineInputBorder(),
                                labelText: "Adicione uma tarefa",
                                hintText: "Ex.: Estudar Flutter."),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String text = todoController.text;

                            if (text.isEmpty) {
                              setState(() {
                                errorText = "O título não pode estar vazio";
                              });
                              return;
                            }

                            setState(() {
                              Todo newTodo =
                                  Todo(title: text, dateTime: DateTime.now());
                              todos.add(newTodo);
                              errorText = null;
                            });
                            todoController.clear();
                            todoRepositories.saveTodoList(todos);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Flexible(
                      child: ListView(
                        children: [
                          for (Todo todo in todos)
                            TodoListItem(
                              todo: todo,
                              onDelete: onDelete,
                              isPressed: pressedTodo == todo,
                              onPress: () {
                                setState(() {
                                  pressedTodo = todo;
                                  showDeleteOnlyOneTodoConfirmationDiolog(todo);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Você possui ${todos.length} tarefas pendentes.",
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: showDeleteTodosConfimationDiolog,
                          child: Text("Limpar Tudo"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  onDelete(Todo todo) {
    setState(() {
      deletedTodo = todo;
      deletedTodoPos = todos.indexOf(todo);
      todos.remove(todo);
    });
    todoRepositories.saveTodoList(todos);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Tarefa '${todo.title}' foi deletada com sucesso!",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: "Desfazer",
        textColor: Colors.deepPurple,
        onPressed: () {
          setState(() {
            todos.insert(deletedTodoPos!, deletedTodo!);
          });
          todoRepositories.saveTodoList(todos);
        },
      ),
    ));
  }

  void showDeleteTodosConfimationDiolog() {
    if (todos.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.warning),
                    Text(
                      " Atenção!",
                    ),
                  ],
                ),
                content:
                Text("Você tem certeza que deseja apagar todas a tarefas?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteAllTodos();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text("Apagar Tudo"),
                  )
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.warning),
                    Text(
                      " Atenção!",
                    ),
                  ],
                ),
                content:
                Text("Não há tarefas para serem apagadas."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: Text("OK"),
                  ),
                ],
              ));
    }
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Todas as $lenTodos tarefas foram deletadas com sucesso!",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        duration: Duration(seconds: 5),
      ));
    });
    todoRepositories.saveTodoList(todos);
  }

  void showDeleteOnlyOneTodoConfirmationDiolog(Todo todo) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.warning),
                  Text(
                    " Atenção!",
                  ),
                ],
              ),
              content: Text(
                  "Você tem certeza que deseja apagar a tarefa '${todo.title}'?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDelete(todo);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text("Apagar"),
                )
              ],
            ));
  }
}
