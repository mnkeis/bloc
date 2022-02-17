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

  @override
  Future<int> clearCompleted() {
    // TODO: implement clearCompleted
    throw UnimplementedError();
  }

  @override
  Future<int> completeAll({required bool isCompleted}) {
    // TODO: implement completeAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTodo(String id) {
    // TODO: implement deleteTodo
    throw UnimplementedError();
  }

  @override
  Stream<List<Todo>> getTodos() {
    return _firestore.collection('todos').snapshots().map(
          (snapshot) => snapshot.docs.map(TodoEx._fromSnapshot).toList(),
        );
  }

  @override
  Future<void> saveTodo(Todo todo) {
    // TODO: implement saveTodo
    throw UnimplementedError();
  }
}

/// {@template firestore_todo_extension}
/// Add methods fromSnapshot and toSnapshot
/// {@nedtemplate}
extension TodoEx on Todo {
  /// Returns a Todo from a firestore snapshot
  static Todo _fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data != null) {
      return Todo.fromJson(data as Map<String, dynamic>);
    }
    throw const FormatException();
  }

  /// returns
}
