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
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseServices _databaseServices = DatabaseServices();


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
          if (snapshot.hasData) {
            List<Todo> todos = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todos.length,
                itemBuilder: (content, index) {
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
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.done,
                                label: "Mark",
                                onPressed: (context) {
                                  _databaseServices.updateTodoStatus(todo.id, true);
                                }
                            ),
                            SlidableAction(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: "Edit",
                                onPressed: (context) async {
                                  _showTaskDialog(context, todo: todo);
                                }
                            ),
                          ],
                        ),
                        startActionPane: ActionPane(
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: "Delete",
                                onPressed: (context) async {
                                  await _databaseServices.deleteTodoTask(todo.id);
                                }
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
                          subtitle: Text(
                            todo.description,
                          ),
                          trailing: Text(
                            '${dt.day}/${dt.month}/${dt.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ),
                  );
                }
            );
          }
          else {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }
        }
    );
  }


  void _showTaskDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController _titleController =
    TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController =
    TextEditingController(text: todo?.description);
    final DatabaseServices _databaseServices = DatabaseServices();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(todo == null ? "Add Task" : "Edit Task",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              )),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: "Title", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: "Description", border: OutlineInputBorder()),
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (todo == null) {
                  await _databaseServices.addTodoTask(
                      _titleController.text, _descriptionController.text);
                } else {
                  await _databaseServices.updateTodo(todo.id,
                      _titleController.text, _descriptionController.text);
                }
                Navigator.pop(context);
              },
              child: Text(todo == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}
