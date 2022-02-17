import 'package:flutter_services_binding/flutter_services_binding.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:flutter_todos/firebase_options_dev.dart';
// import 'package:local_storage_todos_api/local_storage_todos_api.dart';

// ignore_for_file: directives_ordering
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_todos_api/firestore_todos_api.dart';

Future<void> main() async {
  FlutterServicesBinding.ensureInitialized();

  // final todosApi = LocalStorageTodosApi(
  //   plugin: await SharedPreferences.getInstance(),
  // );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final todosApi = FirestoreTodosApi(firestore: FirebaseFirestore.instance);

  bootstrap(todosApi: todosApi);
}
