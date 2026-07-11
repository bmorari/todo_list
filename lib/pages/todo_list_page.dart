import 'package:flutter/material.dart';
import 'package:anotai_app/repositories/todo_repository.dart';
import 'package:anotai_app/widgets/todo_list_item.dart';

import '../models/todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  final timeNow = DateTime.now();
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: todoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adicione uma tarefa',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            floatingLabelStyle: TextStyle(color: Colors.indigo),
                            errorText: errorText,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey[600]!,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          String text = todoController.text;
      
                          if(text.isEmpty) {
                            setState(() {
                              errorText = 'O texto não pode ser vazio!';
                            });
                            return;
                          }
      
                          setState(() {
                            Todo newTodo = Todo(
                              title: text,
                              dateTime: DateTime.now(),
                            );
                            todos.add(newTodo);
                            errorText = null;
                          });
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.all(12.7),
                        ),
                        child: Icon(Icons.add, size: 27, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (Todo todo in todos)
                          TodoListItem(todo: todo, onDelete: onDelete),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ' ${todos.length} tarefas pendentes',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: showAlertDeleteAllTodos,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color.fromARGB(255, 241, 126, 126),
                          padding: EdgeInsets.all(14),
                        ),
                        child: Text('Limpar tudo', style: TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(color: Colors.black),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.grey[50],
        persist: false,
        action: SnackBarAction(
          textColor: Colors.blue,
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
      ),
    );
  }

  void showAlertDeleteAllTodos() {
    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: Text('Deseja deletar tudo?'),
        content: Text('Essa ação deletará todos os itens da sua listagem!'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: deleteAllItens ,
            child: Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAllItens() {
    setState(() {
      todos.clear();
    });
    Navigator.pop(context);
    todoRepository.saveTodoList(todos);
  }
}
