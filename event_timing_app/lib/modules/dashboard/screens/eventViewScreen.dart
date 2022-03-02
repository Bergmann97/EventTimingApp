// import 'package:flutter/cupertino.dart';

// ignore_for_file: file_names


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:event_timing_app/modules/dashboard/screens/commingEvent.dart';
import 'package:event_timing_app/widgets/old_commingEvent.dart';
import 'package:event_timing_app/widgets/old_startedEvent.dart';
import 'package:event_timing_app/widgets/timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventViewPage extends StatefulWidget {
  DocumentSnapshot eventDoc;

  EventViewPage({Key? key, required this.eventDoc}) : super(key: key);

  @override 
  _EventViewPageState createState() => _EventViewPageState(eventDoc: eventDoc);
}

class _EventViewPageState extends State<EventViewPage> {

  DocumentSnapshot eventDoc;
  final db = FirebaseFirestore.instance;

  int _selectedIndex = 0;

  

  _EventViewPageState({Key? key, required this.eventDoc});

  String getEndTime(String time) {
    if (time == "") {
      return "...";
    } else {
      return time;
    }
  }
  
  // CollectionReference collection = FirebaseFirestore.instance.collection("events");

  @override
  Widget build(BuildContext context) {
    return Scaffold();
    //   var _pages = [
    //     Timer(eventDoc: eventDoc),
    //     StartedEvent(eventDoc: eventDoc)
    //   ];
    // if (eventDoc['started']) {
    //   print("HEre");
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Text(eventDoc["name"]),
    //       automaticallyImplyLeading: false,
    //       centerTitle: true,
    //     ),
    //     bottomNavigationBar: BottomNavigationBar( // TODO will be shown when event started
    //       items: const [
    //         BottomNavigationBarItem(
    //           icon: Icon(Icons.timer),
    //           label: "Timer"),
    //         BottomNavigationBarItem(icon: Icon(Icons.list),
    //           label: "Overview"),
    //       ],
    //       currentIndex: _selectedIndex,
    //       onTap: (value) {
    //         setState(() {
    //           _selectedIndex = value;
    //         });
    //       },
    //     ),
    //     body: _pages[_selectedIndex]
    //   );
    //   // return StartedEvent(eventDoc: eventDoc);
    // } else {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Text(eventDoc["name"]),
    //       automaticallyImplyLeading: true,
    //       centerTitle: true,
    //     ),
    //     body: SingleChildScrollView(
    //       child: Column(
    //         children: <Widget> [
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           // DATE VIEW
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               const Text("Date:"),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ), 
    //               Text(eventDoc["startDate"]),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               const Text("-"),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               Text(eventDoc["endDate"]),
    //             ],
    //           ),
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           // TIME VIEW
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               const Text("Time:"),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               Text(eventDoc["startTime"]),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               const Text("-"),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               Text(getEndTime(eventDoc["endTime"])),
    //             ],
    //           ),
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           // PARTICIPANTS NUMBER VIEW
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               const Text("Participants:"),
    //               Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
    //                 child: null
    //               ),
    //               Text(eventDoc["participants"].length.toString()),
    //             ],
    //           ),
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             children: [
    //               const Text("Participants:"),
    //             ],
    //           ),
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           // PARTICIPANT VIEW
    //           Container(
    //             width: MediaQuery.of(context).size.width*0.9,
    //             height: MediaQuery.of(context).size.height*0.5,
    //             color: Colors.grey,
    //             child: ListView.builder(
    //               itemCount: eventDoc['participants'].length,
    //               itemBuilder: (context, index) {
    //                 String p = eventDoc['participants'][index];
    //                 return ListTile(
    //                   // TODO get Participant by the given Index p
    //                   title: Text(p),
    //                   onTap: null, // TODO add editing of participant
    //                   onLongPress: null, // TODO add selection and option to delete of single or more items
    //                 );
    //             })
    //           ),
    //           Padding(
    //             padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*.02),
    //             child: null
    //           ),
    //           ElevatedButton( // TODO switches Look of Event -> 
    //             onPressed: () {
    //               db.collection("events").doc(eventDoc.id).update({"started": true});
    //               Navigator.of(context).pushAndRemoveUntil(
    //                 MaterialPageRoute(builder: (context) => EventViewPage(eventDoc: eventDoc,)),
    //                 (Route<dynamic> route) => false,
    //               );
    //             }, 
    //             child: Text("Start Event!"),
    //           ),
    //         ],
    //       )
    //   )
    // );
  }
}