import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/widgets/addParticipant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  double listHeight = 0.3;
  DocumentSnapshot eventDoc;
  Overview({Key? key, required this.listHeight, required this.eventDoc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OverviewState(listHeight, eventDoc);
}

class _OverviewState extends State<Overview> {
  final db = FirebaseFirestore.instance;

  double listHeight = 0.3;
  DocumentSnapshot eventDoc;
  _OverviewState(this.listHeight, this.eventDoc);

  @override
  Widget build(BuildContext context) {

    Widget list = Text("Actually no Participants :-(");

    if (eventDoc['participants'].length > 0) {
      list = ListView.builder(
        itemCount: eventDoc['participants'].length,
        itemBuilder: (context, index) {
          String p = eventDoc['participants'][index];
          return ListTile(
            // TODO get Participant by the given Index p
            title: Text(p),
            onTap: () {
              showDialog(
                context: context, 
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return FutureBuilder(
                        future: db.collection("participants").doc(p).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return AlertDialog(
                              title: const Text("Something went wrong when loading the Participant"),
                              content: ElevatedButton(
                                child: const Text("OK"),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                              ),
                            );
                          }
                          if (snapshot.hasData && !snapshot.data!.exists) {
                            return AlertDialog(
                              title: const Text("The Participant does not exists"),
                              content: ElevatedButton(
                                child: const Text("OK"),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                              ),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.done) {
                            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                            return UpdateParticipant(ds: data);
                            // return AlertDialog(
                            //   title: Text(data["firstName"] + " " + data["secondName"]),
                            //   content: ElevatedButton(
                            //     child: const Text("OK"),
                            //     onPressed: () {
                            //         Navigator.of(context).pop();
                            //     },
                            //   ),
                            // );
                            // return Text(data["firstName"] + " " + data["secondName"]);
                          }

                          return CircularProgressIndicator();
                        }
                      );
                    }
                  );
                }
              );
            }, // TODO add editing of participant
            onLongPress: null, // TODO add selection and option to delete of single or more items
          );
      });
    }

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width*0.95,
          height: MediaQuery.of(context).size.height*0.2,
          color: Colors.green[100],
          child: const Text("Hier kommt Projekt Zahlen (Date, Time, Num participants)"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.008),
          child: null
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.95,
          height: MediaQuery.of(context).size.height*listHeight,
          color: Colors.yellow[100],
          child: list
        ),
      ],
    );
  }
  
}