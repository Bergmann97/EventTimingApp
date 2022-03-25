import 'package:winapp/model/event.dart';
import 'package:winapp/controllers/firebase.dart';
import 'package:winapp/controllers/participant_organizer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class EventOrganizer {
  static const String eventCollection = "events";

  createEvent(Event event) async {
    DocumentReference? eid = await FirebaseHelper().addDocument(
      eventCollection, 
      event.toJSON()
    );
    FirebaseHelper().updateDocument(eventCollection, eid!, {'eid': eid});
  }

  getEventById(String eid) {
    FirebaseHelper().readDocumentById(eventCollection, eid);
  }

  updateEvent(Event event) {
    FirebaseHelper().updateDocumentById(eventCollection, event.getEID(), event.toJSON());
  }

  updateEventById(String eid, Map<String, dynamic> data) {
    FirebaseHelper().updateDocumentById(eventCollection, eid, data);
  }

  deleteEvent(Event event) {
    FirebaseHelper().deleteDocumentById(eventCollection, event.getEID());
  }

  deleteEventById(String eid) {
    FirebaseHelper().deleteDocumentById(eventCollection, eid);
  }

  Event fromSnapshot(Map<String, dynamic> snapshot) {
    if (snapshot['generatedParticipants']) {
      return Event(
        snapshot['eid'], 
        snapshot['cid'], 
        snapshot['title'], 
        snapshot['maxNumParticipants'], 
        snapshot['participants'], 
        snapshot['planedStartDate'], 
        snapshot['endDate'], 
        snapshot['generatedParticipants']
      );
    } else {
      List<Map<String, dynamic>> participants = snapshot['participants'];
      Event event = Event(
        snapshot['eid'], 
        snapshot['cid'], 
        snapshot['title'], 
        snapshot['maxNumParticipants'], 
        snapshot['participants'], 
        snapshot['planedStartDate'], 
        snapshot['endDate'], 
        snapshot['generatedParticipants']
      );
      for (Map<String, dynamic> participant in participants) {
        event.addParticipant(ParticipantOrganizer().fromSnapshot(participant));
      }
      return event;
    }
  }
}