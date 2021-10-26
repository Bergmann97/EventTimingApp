// ignore_for_file: file_names

import 'package:event_timing_app/modules/dashboard/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParticipantCreationPage extends StatefulWidget {
  String uid = "";
  Event event;

  ParticipantCreationPage({Key? key, required this.uid, required this.event}) : super(key: key);
  
  @override 
  _ParticipantCreationPageState createState() => _ParticipantCreationPageState();
}

class _ParticipantCreationPageState extends State<ParticipantCreationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event Participants"),
        // automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: null
            ),
            Text("Hier sollen Teilnehmer erstellt werden!"),
          ],
        ),
      ),
    );
  }
}