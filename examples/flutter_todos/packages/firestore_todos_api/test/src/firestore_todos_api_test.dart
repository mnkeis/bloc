// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firestore_todos_api/firestore_todos_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_api/todos_api.dart';

class MockFirebaseFirestore extends Mock
    with LegacyEquality
    implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    with LegacyEquality
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    with LegacyEquality
    implements DocumentReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

mixin LegacyEquality {
  @override
  bool operator ==(dynamic other) => false;

  @override
  int get hashCode => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': const <String, String>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return <String, dynamic>{
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': const <String, String>{},
      };
    }

    return null;
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  const id = 'mock-id';
  const title = 'title-1';
  const description = 'description 4';

  final mockTodo = Todo(
    id: 'mock-id',
    title: 'title',
    description: 'description',
  );
  group('FirestoreTodosApi', () {
    late FirebaseFirestore firestore;
    late CollectionReference<Map<String, dynamic>> todosCollection;
    late FirestoreTodosApi firestoreTodosApi;
    late DocumentReference mockDocumentReference;

    final todos = [
      Todo(
        id: '1',
        title: 'title 1',
        description: 'description 1',
      ),
      Todo(
        id: '2',
        title: 'title 2',
        description: 'description 2',
      ),
      Todo(
        id: '3',
        title: 'title 3',
        description: 'description 3',
        isCompleted: true,
      ),
    ];

    setUp(() {
      firestore = MockFirebaseFirestore();
      todosCollection = MockCollectionReference();
      firestoreTodosApi = FirestoreTodosApi(
        firestore: firestore,
      );
      when(() => firestore.collection('todos')).thenReturn(todosCollection);
    });

    FirestoreTodosApi createSubject() {
      return FirestoreTodosApi(firestore: firestore);
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });

      group('initializes the todos stream', () {
        test('with existing todos if present', () {
          final subject = createSubject();

          expect(
              subject.getTodos(),
              emits(subject.todosCollection
                ..orderBy('id').snapshots().map(
                      (snapshot) => snapshot.docs.map((e) => e.data()).toList(),
                    )));

          // verify(() => firestore.collection('Todos')).called(1);
        });

        //   test('fetches stream of todos', () async {
        //     final subject = createSubject();
        //     when(() => firestoreTodosApi.getTodos())
        //         .thenAnswer((_) => Stream.value([]));

        //     await expectLater(
        //       subject.getTodos(),
        //       emitsInOrder(const <Todo>[]),
        //     );

        //     // final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
        //     // when(() => mockQueryDocumentSnapshot.id).thenReturn(id);
        //     // when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        //     //   'title': title,
        //     //   'description': description,
        //     // });
        //     // final mockQuerySnapshot = MockQuerySnapshot();
        //     // when(() => mockQuerySnapshot.docs)
        //     //     .thenReturn([mockQueryDocumentSnapshot]);
        //     // when(() => mockTodosCollection.snapshots()).thenAnswer(
        //     //   (_) => Stream<QuerySnapshot>.fromIterable([mockQuerySnapshot]),
        //     // );

        //     // await expectLater(
        //     //     mockFirestoreTodosApi.getTodos(),
        //     //     emitsInOrder([
        //     //       [mockTodo]
        //     //     ]),);
        //   });
      });

      ///end of group
    });
  });
}

/// https://github.com/felangel/bloc/issues/2257
/// https://utkarshkore.medium.com/writing-unit-tests-in-flutter-with-firebase-firestore-72f99be85737
