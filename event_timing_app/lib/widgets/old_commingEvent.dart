// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/modules/dashboard/screens/eventViewScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OldCommingEvent extends StatefulWidget {
  DocumentSnapshot eventDoc;

  OldCommingEvent({Key? key, required this.eventDoc}) : super(key: key);
  
  @override 
  _OldCommingEventState createState() => _OldCommingEventState(eventDoc);
}

class _OldCommingEventState extends State<OldCommingEvent> {

  DocumentSnapshot eventDoc;
  final db = FirebaseFirestore.instance;
  _OldCommingEventState(this.eventDoc);

  String getEndTime(String time) {
    if (time == "") {
      return "...";
    } else {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventDoc["name"]),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            // DATE VIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Date:"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ), 
                Text(eventDoc["startDate"]),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                const Text("-"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                Text(eventDoc["endDate"]),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            // TIME VIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Time:"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                Text(eventDoc["startTime"]),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                const Text("-"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                Text(getEndTime(eventDoc["endTime"])),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            // PARTICIPANTS NUMBER VIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Participants:"),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                  child: null
                ),
                Text(eventDoc["participants"].length.toString()),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Participants:"),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            // PARTICIPANT VIEW
            Container(
              width: MediaQuery.of(context).size.width*0.9,
              height: MediaQuery.of(context).size.height*0.5,
              color: Colors.grey,
              child: ListView.builder(
                itemCount: eventDoc['participants'].length,
                itemBuilder: (context, index) {
                  String p = eventDoc['participants'][index];
                  return ListTile(
                    // TODO get Participant by the given Index p
                    title: Text(p),
                    onTap: null, // TODO add editing of participant
                    onLongPress: null, // TODO add selection and option to delete of single or more items
                  );
              })
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
              child: null
            ),
            ElevatedButton( // TODO switches Look of Event -> 
                onPressed: () {
                  db.collection("events").doc(eventDoc.id).update({"started": true});
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => EventViewPage(eventDoc: eventDoc,)),
                    (Route<dynamic> route) => false,
                  );
                }, 
                child: Text("Start Event!"),
              ),
          ],
        ),
      ),
    );
  }

}




// class CommingEvent extends StatelessWidget {
//   DocumentSnapshot eventDoc;
//   final db = FirebaseFirestore.instance;

//   CommingEvent({
//     Key? key,
//     required this.eventDoc
//   }) : super(key: key);

//   String getEndTime(String time) {
//     if (time == "") {
//       return "...";
//     } else {
//       return time;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//         child: Column(
//           children: <Widget> [
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//             // DATE VIEW
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text("Date:"),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ), 
//                 Text(eventDoc["startDate"]),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 const Text("-"),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 Text(eventDoc["endDate"]),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//             // TIME VIEW
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text("Time:"),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 Text(eventDoc["startTime"]),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 const Text("-"),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 Text(getEndTime(eventDoc["endTime"])),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//             // PARTICIPANTS NUMBER VIEW
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text("Participants:"),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
//                   child: null
//                 ),
//                 Text(eventDoc["participants"].length.toString()),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 const Text("Participants:"),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//             // PARTICIPANT VIEW
//             Container(
//               width: MediaQuery.of(context).size.width*0.9,
//               height: MediaQuery.of(context).size.height*0.5,
//               color: Colors.grey,
//               child: ListView.builder(
//                 itemCount: eventDoc['participants'].length,
//                 itemBuilder: (context, index) {
//                   String p = eventDoc['participants'][index];
//                   return ListTile(
//                     // TODO get Participant by the given Index p
//                     title: Text(p),
//                     onTap: null, // TODO add editing of participant
//                     onLongPress: null, // TODO add selection and option to delete of single or more items
//                   );
//               })
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
//               child: null
//             ),
//           ],
//         ),
//       );
//   }
// }