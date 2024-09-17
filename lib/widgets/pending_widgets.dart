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
                         style: TextStyle(
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
}
