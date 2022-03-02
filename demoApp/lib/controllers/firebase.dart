import 'package:demo_app/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  final db = FirebaseFirestore.instance;

  FirebaseHelper();

  Future<DocumentReference?> addDocument(String collection, var object) async {
    try {
      DocumentReference docRef = await db.collection(collection).add(object);
      print("Document created!");
      return docRef;
    } catch (e) {
      print(e);
      return null;
    }
  }

  updateDocument(String collection, DocumentReference docRef, Map<String, Object?> updatedData) async {
    try {
      db.collection(collection).doc(docRef.id).update(updatedData);
      print("Document updated!");
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> readDocument(String collection, DocumentReference docRef) async {
    try {
      var doc = await db.collection(collection).doc(docRef.id).get();
      return doc.data();
    } catch (e) {
      print(e);
      return null;
    }
  }

  deleteDocument(String collection, DocumentReference docRef) async {
    try {
      db.collection(collection).doc(docRef.id).delete();
      print("Document deleted!");
    } catch (e) {
      print(e);
    }
  }

  getAllData(String collection, String? fieldname) async {
    QuerySnapshot querySnapshot = await db.collection(collection).get();
    final allData = querySnapshot.docs.map((doc) => doc.id).toList();
    print(allData);

    if (fieldname != null) {
      final allData2 = querySnapshot.docs.map((doc) => doc.get(fieldname)).toList();
      print(allData2);
    }
  }

  Future<List<Event>>? getUserDocuments(String collection, String uid) async {
    QuerySnapshot snapshot = await db.collection(collection)
                                .where("uid", isEqualTo: uid)
                                .get();
    
    List<Event> docs = [];

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((element) {
        Map<String, dynamic> doc = element.data() as Map<String, dynamic>;
        Event event = Event(
          doc["eid"],
          doc["uid"],
          doc["name"],
          DateTime.parse(doc["startdate"]),
          DateTime.parse(doc["enddate"]),
          doc["maxNumParticipants"],
          doc["participants"],
        );
        docs.add(event);
      });
    }

    return docs;
  }


}