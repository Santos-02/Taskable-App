import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.json');
  }

  Future<void> saveTasks() async {
    final file = await _localFile;
    final json = TaskModel.encode(tasks);
    await file.writeAsString(json);
  }

  Future<void> loadTasks() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          tasks = TaskModel.decode(contents);
        });
      }
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
    }
  }

  void _handleTaskFormResult(dynamic result, {int? editIndex}) {
    if (result != null && result is TaskModel) {
      setState(() {
        if (editIndex != null) {
          result.isCompleted = tasks[editIndex].isCompleted;
          tasks[editIndex] = result;
        } else {
          result.isCompleted = false;
          tasks.add(result);
        }
        saveTasks();
      });
    }
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () {
              Navigator.pushNamed(context, '/tags', arguments: tasks);
            },
          ),
        ],
      ),
      body:
          tasks.isEmpty
              ? const Center(
                child: Text(
                  'Nenhuma tarefa criada',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            toggleTaskCompletion(index);
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        if (task.tag != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              task.tag!,
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      task.description,
                      style: TextStyle(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey[600] : null,
                      ),
                    ),
                    subtitle:
                        task.dateTime != null
                            ? Text(
                              '${task.dateTime!.day}/${task.dateTime!.month}/${task.dateTime!.year} '
                              '${task.dateTime!.hour}:${task.dateTime!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                decoration:
                                    task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                color:
                                    task.isCompleted ? Colors.grey[500] : null,
                              ),
                            )
                            : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              task.isCompleted
                                  ? null
                                  : () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/form',
                                      arguments: {'task': task},
                                    );
                                    _handleTaskFormResult(
                                      result,
                                      editIndex: index,
                                    );
                                  },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/form');
            _handleTaskFormResult(result);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Nova Tarefa'),
        ),
      ),
    );
  }
}
