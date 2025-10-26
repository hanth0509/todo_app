import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App V2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TodoHomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: (value) => setState(() => _isDarkMode = value),
      ),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const TodoHomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _todos = [];

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task before adding!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _todos.add({'title': text, 'done': false});
      _controller.clear();
    });
  }

  void _toggleDone(int index) {
    setState(() {
      _todos[index]['done'] = !_todos[index]['done'];
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _editTodoDialog(int index) {
    final editController = TextEditingController(text: _todos[index]['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Enter new task name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                setState(() {
                  _todos[index]['title'] = newText;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📱 Responsive width (max 600)
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onToggleTheme,
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Input Field + Add Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Enter new task',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _addTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // List of Todos
                Expanded(
                  child: _todos.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: _todos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            final done = todo['done'] as bool;

                            return Card(
                              elevation: 2,
                              shadowColor: Colors.indigo.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Checkbox(
                                  value: done,
                                  onChanged: (_) => _toggleDone(index),
                                  activeColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                title: Text(
                                  todo['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: done
                                        ? Colors.grey.shade600
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueAccent),
                                      onPressed: () => _editTodoDialog(index),
                                    ),
                                    GestureDetector(
                                      onTap: () => _deleteTodo(index),
                                      behavior: HitTestBehavior.opaque,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.delete,
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Trạng thái rỗng
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No tasks yet!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Add your first task to get started .'),
        ],
      ),
    );
  }
}
