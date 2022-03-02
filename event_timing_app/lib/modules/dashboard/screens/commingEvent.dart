// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/modules/dashboard/screens/startedEvent.dart';
import 'package:event_timing_app/widgets/addParticipant.dart';
import 'package:event_timing_app/widgets/overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommingEvent extends StatefulWidget {
  DocumentSnapshot eventDoc;
  CommingEvent({Key? key, required this.eventDoc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommingEventState(eventDoc);
}

class _CommingEventState extends State<CommingEvent> {
  final db = FirebaseFirestore.instance;

  DocumentSnapshot eventDoc;
  _CommingEventState(this.eventDoc);

  void addParticipant() {
    showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AddParticipant();
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventDoc["name"]),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.red[100],
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.008),
              child: null
            ),
            Overview(listHeight: 0.46,eventDoc: eventDoc,),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.008),
              child: null
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.95,
              height: MediaQuery.of(context).size.height*0.08,
              color: Colors.blue[100],
              child: const ElevatedButton(
                onPressed: null,
                // onPressed: () {
                //     // TODO alert Dialog: Wollen sie das Event wirklich starten? Danach kann kein Teilnehmer mehr hinzugefügt werden
                //     db.collection("events").doc(eventDoc.id).update({"started": true});
                //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StartedEvent(eventDoc: eventDoc)));
                // }, 
                child: Text("EVENT STARTEN!")
              ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addParticipant,
        child: Icon(Icons.add),
      ),
    );
  }

}