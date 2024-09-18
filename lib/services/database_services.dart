import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/todo_model.dart';

class DatabaseServices {
  final CollectionReference todoCollection =
  FirebaseFirestore.instance.collection("todos");
  final User? user = FirebaseAuth.instance.currentUser;

  // Add to do task
  Future<void> addTodoTask(String title, String description) async {
    try {
      await todoCollection.add({
        'uid': user!.uid,
        'title': title,
        'description': description,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add todo task: $e');
    }
  }

  // Update to do task
  Future<void> updateTodo(String id, String title, String description) async {
    try {
      await todoCollection.doc(id).update({
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  // Update todo status
  Future<void> updateTodoStatus(String id, bool completed) async {
    try {
      await todoCollection.doc(id).update({'completed': completed});
    } catch (e) {
      throw Exception('Failed to update todo status: $e');
    }
  }

  // Delete to do task
  Future<void> deleteTodoTask(String id) async {
    try {
      await todoCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo task: $e');
    }
  }

  // Get pending tasks
  Stream<List<Todo>> get todos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: false)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  // Get completed tasks
  Stream<List<Todo>> get completedTodos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  List<Todo> _todoListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Todo(
        id: doc.id,
        title: doc['title'] ?? '',
        description: doc['description'] ?? '',
        completed: doc['completed'] ?? false,
        timeStamp: doc['createdAt'] ?? Timestamp.now(),
      );
    }).toList();
  }
}