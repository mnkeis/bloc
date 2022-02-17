// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_todos_api/firestore_todos_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  final firestoreInstance = MockFirebaseFirestore();

  setUp(() {
    registerFallbackValue(firestoreInstance);
  });

  group('FirestoreTodosApi', () {
    test('can be instantiated', () {
      expect(
        FirestoreTodosApi(
          firestore: firestoreInstance,
          userId: '',
        ),
        isNotNull,
      );
    });
  });
}
