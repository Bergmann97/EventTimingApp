import 'package:demo_app/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FirebaseHelper {
  final db = FirebaseFirestore.instance;

  FirebaseHelper();

  Future<DocumentReference?> addDocument(String collection, var object) async {
    try {
      DocumentReference docRef = await db.collection(collection).add(object);
      log("Document created!");
      return docRef;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  updateDocument(String collection, DocumentReference docRef, Map<String, Object?> updatedData) async {
    try {
      db.collection(collection).doc(docRef.id).update(updatedData);
      log("Document updated!");
    } catch (e) {
      log(e.toString());
    }
  }

  updateDocumentById(String collection, String docRef, Map<String, Object?> updatedData) async {
    try {
      db.collection(collection).doc(docRef).update(updatedData);
      log("Document updated!");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Map<String, dynamic>?> readDocument(String collection, DocumentReference docRef) async {
    try {
      var doc = await db.collection(collection).doc(docRef.id).get();
      return doc.data();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> readDocumentById(String collection, String docRef) async {
    try {
      var doc = await db.collection(collection).doc(docRef).get();
      return doc.data();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  deleteEventDocsWithParticipant(String pid) async {
    try {
      QuerySnapshot querySnapshot = await db.collection("events_new").get();
      for (var snapshot in querySnapshot.docs) {
        log((snapshot.data() as Map)['name'].toString());
        Map event = (snapshot.data() as Map);
        List parts = event['participants'];
        for (Map p in parts) {
          if (p['uid'] == pid) {
            log(parts.toString());
            parts.removeWhere((element) => element['uid'] == pid);
            await updateDocumentById(
              "events_new", 
              event['eid'], 
              {
                'participants': parts,
              }
            );
            log(parts.toString());
            return true;
          }
        } 
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  deleteDocument(String collection, DocumentReference docRef) async {
    try {
      db.collection(collection).doc(docRef.id).delete();
      log("Document deleted!");
    } catch (e) {
      log(e.toString());
    }
  }

  deleteDocumentById(String collection, String id) async {
    try {
      db.collection(collection).doc(id).delete();
      log("Document deleted!");
    } catch (e) {
      log(e.toString());
    }
  }

  getAllData(String collection, String? fieldname) async {
    QuerySnapshot querySnapshot = await db.collection(collection).get();
    // final allData = querySnapshot.docs.map((doc) => doc.id).toList();
    // print(allData);

    if (fieldname != null) {
      querySnapshot.docs.map((doc) => doc.get(fieldname)).toList();
      // print(allData2);
    }
  }

  Future<List<Event>>? getUserDocuments(String collection, String uid) async {
    QuerySnapshot snapshot = await db.collection(collection)
                                .where("uid", isEqualTo: uid)
                                .get();
    
    List<Event> docs = [];

    if (snapshot.docs.isNotEmpty) {
      for (var element in snapshot.docs) {
        Map<String, dynamic> doc = element.data() as Map<String, dynamic>;
        Event event = Event(
          doc["eid"],
          doc["uid"],
          doc["name"],
          doc["startdate"],
          doc["enddate"],
          doc["maxNumParticipants"],
          doc["participants"],
          doc["generatedParticipants"],
        );
        docs.add(event);
      }
    }

    return docs;
  }

  Future<Map<String, dynamic>?> getUserprofil(String collection, String uid) async {
    try {
      var doc = await db.collection(collection).doc(uid).get();
      return doc.data();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }


}