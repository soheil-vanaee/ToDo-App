import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({Key? key}) : super(key: key);

  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  late TextEditingController _todoController;
  late List<String> todos;
  late List<String> filteredTodos;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController();
    todos = [];
    filteredTodos = [];
    _loadTodos(); // Load TODOs when the app starts
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      todos = prefs.getStringList('todos') ?? [];
      filteredTodos = todos;
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', todos);
  }

  void _addTodo() {
    String newTodo = _todoController.text.trim();
    if (newTodo.isNotEmpty && !todos.contains(newTodo)) {
      setState(() {
        todos.add(newTodo);
        filteredTodos = todos; // Make sure filteredTodos includes all todos
        _todoController.clear();
        _saveTodos(); // Save TODOs after adding a new one
      });
    }
  }

  void _filterTodos(String query) {
    setState(() {
      filteredTodos = todos
          .where((todo) => todo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _todoController,
                    onSubmitted: (value) {
                      _addTodo();
                      Navigator.of(context).pop();
                    },
                    decoration: InputDecoration(
                      labelText: "Enter your todo",
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addTodo();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTextField() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              isSearching = false;
              _filterTodos('');
            });
          },
        ),
        Expanded(
          child: TextField(
            onChanged: (value) {
              _filterTodos(value);
            },
            decoration: InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 75, 10, 188),
                  const Color.fromARGB(255, 26, 43, 138),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.assignment,
                    color: Colors.deepPurple,
                    size: 40,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "My TODO ;)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isSearching
                  ? _buildSearchTextField()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "todos",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: filteredTodos.isNotEmpty
                    ? filteredTodos.length
                    : todos.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(filteredTodos.isNotEmpty
                        ? filteredTodos[index]
                        : todos[index]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        todos.removeAt(index);
                        // filteredTodos.removeAt(index);
                        _saveTodos(); // Save TODOs after removing one
                      });
                    },
                    background: Container(
                      color: Colors.deepPurple,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.deepPurple,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTileWithCheckbox(
                      title: filteredTodos.isNotEmpty
                          ? filteredTodos[index]
                          : todos[index],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 72, 26, 150),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }
}

class ListTileWithCheckbox extends StatefulWidget {
  final String title;

  const ListTileWithCheckbox({required this.title});

  @override
  _ListTileWithCheckboxState createState() => _ListTileWithCheckboxState();
}

class _ListTileWithCheckboxState extends State<ListTileWithCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
            Text(
              widget.title,
              style: TextStyle(
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
