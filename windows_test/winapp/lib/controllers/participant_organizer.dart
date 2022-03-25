import 'package:winapp/model/participant.dart';
import 'package:winapp/controllers/firebase.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class ParticipantOrganizer{
  static const String participantCollection = "participants";
  FirebaseHelper fb = FirebaseHelper();

  createEvent(CreatedParticipant participant) async {
    DocumentReference? pid = await fb.addDocument(participantCollection, participant.toJSON());
    fb.updateDocument(participantCollection, pid!, {'pid': pid});
  }

  getEventById(String pid) {
    fb.readDocumentById(participantCollection, pid);
  }

  updateEvent(CreatedParticipant participant) {
    fb.updateDocumentById(participantCollection, participant.getPID(), participant.toJSON());
  }

  updateEventById(String pid, Map<String, dynamic> data) {
    fb.updateDocumentById(participantCollection, pid, data);
  }

  deleteEvent(CreatedParticipant participant) {
    fb.deleteDocumentById(participantCollection, participant.getPID());
  }

  deleteEventById(String pid) {
    fb.deleteDocumentById(participantCollection, pid);
  }

  CreatedParticipant fromSnapshot(Map<String, dynamic> snapshot) {
    return CreatedParticipant(
      snapshot['cid'], 
      snapshot['pid'], 
      snapshot['firstname'], 
      snapshot['secondname'], 
      snapshot['sex'], 
      snapshot['birthdate'], 
      snapshot['email'],
      snapshot['events']
    );
  }
}