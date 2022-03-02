// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

Future<QueryDocumentSnapshot<Object?>?> getDocument(String collection, String doc) async {
  QueryDocumentSnapshot? result;

  await db.collection(collection).get().then((querySnapshot) {
    for (var element in querySnapshot.docs) {
      if (element.id == doc) {
        result = element;
      }
    }
  });

  return result;
}