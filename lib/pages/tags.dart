import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class Tag {
  final String name;

  Tag({required this.name});
}

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  final List<Tag> tags = [
    Tag(name: 'Trabalho'),
    Tag(name: 'Faculdade'),
    Tag(name: 'Casa'),
  ];

  List<TaskModel> tasks = [];

  final TextEditingController _controller = TextEditingController();

  void _addTag() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        tags.add(Tag(name: name));
        _controller.clear();
      });
      _saveTags();
    }
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tagNames = tags.map((tag) => tag.name).toList();
    await prefs.setStringList('tags', tagNames);
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tagNames = prefs.getStringList('tags');

    setState(() {
      if (tagNames != null) {
        tags.clear();
        tags.addAll(tagNames.map((name) => Tag(name: name)));
      } else {
        final defaultTags = ['Trabalho', 'Faculdade', 'Casa'];
        tags.clear();
        tags.addAll(defaultTags.map((name) => Tag(name: name)));
        prefs.setStringList('tags', defaultTags);
      }
    });
  }

  void _deleteTag(int index) async {
    setState(() {
      tags.removeAt(index);
    });
    await _saveTags();
  }

  bool _isTagInUse(String tagName) {
    return tasks.any((task) => task.tag == tagName);
  }

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args != null && args is List<TaskModel>) {
      tasks = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Tags')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Nome da Tag'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTag,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isInUse = _isTagInUse(tag.name);

                  return ListTile(
                    title: Text(tag.name),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: isInUse ? Colors.grey : Colors.red,
                      ),
                      onPressed: isInUse ? null : () => _deleteTag(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
