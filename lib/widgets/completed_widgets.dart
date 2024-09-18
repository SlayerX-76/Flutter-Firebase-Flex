import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_list/model/todo_model.dart';
import 'package:flex_list/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CompletedWidgets extends StatefulWidget {
  const CompletedWidgets({super.key});

  @override
  State<CompletedWidgets> createState() => _CompletedWidgetsState();
}

class _CompletedWidgetsState extends State<CompletedWidgets> {
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
      stream: _databaseServices.completedTodos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No completed tasks'));
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
                color: Colors.white54,
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
                      icon: Icons.undo,
                      label: "Undo",
                      onPressed: (context) async {
                        try {
                          await _databaseServices.updateTodoStatus(todo.id, false);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error marking task as pending: $e')),
                          );
                        }
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
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    todo.description,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
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
}