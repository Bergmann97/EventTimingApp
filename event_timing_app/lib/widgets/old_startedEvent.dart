// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/widgets/old_commingEvent.dart';
import 'package:event_timing_app/widgets/eventOverview.dart';
import 'package:event_timing_app/widgets/timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OldStartedEvent extends StatefulWidget {
  DocumentSnapshot eventDoc;

  OldStartedEvent({Key? key, required this.eventDoc}) : super(key: key);
  
  @override 
  _OldStartedEventState createState() => _OldStartedEventState(eventDoc);
}

class _OldStartedEventState extends State<OldStartedEvent> {

  DocumentSnapshot eventDoc;
  int _selectedIndex = 0;

  _OldStartedEventState(this.eventDoc);

  String getEndTime(String time) {
    if (time == "") {
      return "...";
    } else {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _pages = [
      Timer(eventDoc: eventDoc),
      EventOverview(eventDoc: eventDoc)
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(eventDoc["name"]),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar( // TODO will be shown when event started
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: "Timer"),
          BottomNavigationBarItem(icon: Icon(Icons.list),
            label: "Overview"),
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
      body: _pages[_selectedIndex]
    );
  }
}

// class StartedEvent extends StatelessWidget {
//   DocumentSnapshot eventDoc;
//   int _selectedIndex = 0;

//   StartedEvent({
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
//     // Widget body = StartedEvent(eventDoc: eventDoc);
//     var _pages = [
//         Timer(eventDoc: eventDoc),
//         StartedEvent(eventDoc: eventDoc)
//       ];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(eventDoc["name"]),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//       ),
//       bottomNavigationBar: BottomNavigationBar( // TODO will be shown when event started
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.timer),
//             label: "Timer"),
//           BottomNavigationBarItem(icon: Icon(Icons.list),
//             label: "Overview"),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: (value) {
//           setState(() {
//             _selectedIndex = value;
//           });
//         },
//       ),
//       body: _pages[_selectedIndex]
//     );

//     return EventOverview(eventDoc: eventDoc,);
//   }
// }