import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_list/model/todo_model.dart';
import 'package:flex_list/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PendingWidgets extends StatefulWidget {
  const PendingWidgets({super.key});

  @override
  State<PendingWidgets> createState() => _PendingWidgetsState();
}

class _PendingWidgetsState extends State<PendingWidgets> {
  final DatabaseServices _databaseServices = DatabaseServices();
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseServices.todos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pending tasks'));
        }

        List<Todo> todos = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            Todo todo = todos[index];
            final DateTime dt = todo.timeStamp.toDate();
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Slidable(
                key: ValueKey(todo.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.done,
                      label: "Mark",
                      onPressed: (context) async {
                        try {
                          await _databaseServices.updateTodoStatus(todo.id, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error marking task as done: $e')),
                          );
                        }
                      },
                    ),
                    SlidableAction(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: "Edit",
                      onPressed: (context) {
                        _showTaskDialog(context, todo: todo);
                      },
                    ),
                  ],
                ),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: "Delete",
                      onPressed: (context) async {
                        try {
                          await _databaseServices.deleteTodoTask(todo.id);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting task: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    todo.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(todo.description),
                  trailing: Text(
                    '${dt.day}/${dt.month}/${dt.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTaskDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController titleController = TextEditingController(text: todo?.title);
    final TextEditingController descriptionController = TextEditingController(text: todo?.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            todo == null ? "Add Task" : "Edit Task",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  if (todo == null) {
                    await _databaseServices.addTodoTask(
                      titleController.text,
                      descriptionController.text,
                    );
                  } else {
                    await _databaseServices.updateTodo(
                      todo.id,
                      titleController.text,
                      descriptionController.text,
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error ${todo == null ? 'adding' : 'updating'} task: $e')),
                  );
                }
              },
              child: Text(todo == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}