import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos_api/todos_api.dart';

/// {@template firestore_todos_api}
/// Firestore implementation for the Todos example
/// {@endtemplate}
class FirestoreTodosApi implements TodosApi {
  /// {@macro firestore_todos_api}
  FirestoreTodosApi({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// a pointer to the firestore collection
  late final todosCollection = _firestore.collection('todos');

  /// This stream orders the [Todo]'s by the
  /// time they were created, and then converts
  /// them from a [DocumentSnapshot] into
  /// a [Todo]
  @override
  Stream<List<Todo>> getTodos() {
    return todosCollection.orderBy('time').snapshots().map(
          (snapshot) => snapshot.docs.map(TodoX._fromSnapshot).toList(),
        );
  }

  /// This method first checks whether or not a todo exists
  /// If it doesn't, then we add a timestamp to the todo in
  /// order to preserve the order they were added
  /// Else, we update the existing one
  @override
  Future<void> saveTodo(Todo todo) async {
    final check = await todosCollection.where('id', isEqualTo: todo.id).get();

    if (check.docs.isEmpty) {
      final output = todo.toJson()
        ..putIfAbsent('time', () => Timestamp.now().seconds.toString());

      await todosCollection.add(output);
    } else {
      final currentTodoId = check.docs[0].reference.id;
      await todosCollection.doc(currentTodoId).update(todo.toJson());
    }
  }

  /// This method first checks to see if the todo
  /// exists, and if so it deletes it
  // TODO(fix): check out dismissiable bug

  @override
  Future<void> deleteTodo(String id) async {
    final check = await todosCollection.where('id', isEqualTo: id).get();

    if (check.docs.isEmpty) {
      throw TodoNotFoundException();
    } else {
      final currentTodoId = check.docs[0].reference.id;
      await todosCollection.doc(currentTodoId).delete();
    }
  }

  /// This method uses the Batch write api for
  /// executing multiple operations in a single operation,
  /// which in this case is to delete all the todos that
  /// are marked completed
  @override
  Future<int> clearCompleted() {
    final batch = FirebaseFirestore.instance.batch();
    return todosCollection
        .where('isCompleted', isEqualTo: true)
        .get()
        .then((querySnapshot) {
      final completedTodosAmount = querySnapshot.docs.length;
      for (final document in querySnapshot.docs) {
        batch.delete(document.reference);
      }
      batch.commit();
      return completedTodosAmount;
    });
  }

  /// This method uses the Batch write api for
  /// executing multiple operations in a single operation,
  /// which in this case is to mark all the todos as
  /// completed
  @override
  Future<int> completeAll({required bool isCompleted}) {
    final batch = FirebaseFirestore.instance.batch();
    return todosCollection.get().then((querySnapshot) {
      final completedTodosAmount = querySnapshot.docs.length;
      for (final document in querySnapshot.docs) {
        final completedTodo =
            Todo.fromJson(document.data()).copyWith(isCompleted: true);
        batch.update(document.reference, completedTodo.toJson());
      }
      batch.commit();
      return completedTodosAmount;
    });
  }
}

/// {@template firestore_todo_extension}
/// Add methods fromSnapshot and toSnapshot
/// {@nedtemplate}
extension TodoX on Todo {
  /// Returns a Todo from a firestore snapshot
  static Todo _fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data != null) {
      return Todo.fromJson(data as Map<String, dynamic>);
    }
    throw const FormatException();
  }
}
