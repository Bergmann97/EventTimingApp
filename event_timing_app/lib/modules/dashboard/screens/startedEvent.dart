// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/widgets/overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartedEvent extends StatefulWidget {
  DocumentSnapshot eventDoc;
  StartedEvent({Key? key, required this.eventDoc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartedEventState(eventDoc);
}

class _StartedEventState extends State<StartedEvent> {
  DocumentSnapshot eventDoc;
  _StartedEventState(this.eventDoc);

  int _selectedItem = 0;
  
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Container(
        color: Colors.green[200],
        child: const Center(
          child: Text("Dieses Event hat schon begonnen (TIMER)"),
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.red[100],
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.008),
                child: null
              ),
              Overview(listHeight: 0.575, eventDoc: eventDoc,),
            ],
          )
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Started Event"),
        automaticallyImplyLeading: true,
      ),
      body: _pages[_selectedItem],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: "Timer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Overview",
          ),
        ],
        currentIndex: _selectedItem,
        onTap: (value) {
          setState(() {
            _selectedItem = value;
          });
        },
      ),
    );
  }

}