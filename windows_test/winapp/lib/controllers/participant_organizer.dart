import 'package:winapp/model/participant.dart';
import 'package:winapp/controllers/firebase.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class ParticipantOrganizer{
  static const String participantCollection = "participants";

  createEvent(CreatedParticipant participant) async {
    DocumentReference? pid = await FirebaseHelper().addDocument(
      participantCollection, 
      participant.toJSON()
    );
    FirebaseHelper().updateDocument(participantCollection, pid!, {'pid': pid});
  }

  getEventById(String pid) {
    FirebaseHelper().readDocumentById(participantCollection, pid);
  }

  updateEvent(CreatedParticipant participant) {
    FirebaseHelper().updateDocumentById(participantCollection, participant.getPID(), participant.toJSON());
  }

  updateEventById(String pid, Map<String, dynamic> data) {
    FirebaseHelper().updateDocumentById(participantCollection, pid, data);
  }

  deleteEvent(CreatedParticipant participant) {
    FirebaseHelper().deleteDocumentById(participantCollection, participant.getPID());
  }

  deleteEventById(String pid) {
    FirebaseHelper().deleteDocumentById(participantCollection, pid);
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