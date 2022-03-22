import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/event.dart';
import 'package:demo_app/screens/events/createEventScreen.dart';
import 'package:demo_app/screens/events/viewEventScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';


class EventView extends StatefulWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventViewState();

}

class _EventViewState extends State<EventView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  DocumentReference? docRef;
  FirebaseHelper fb = FirebaseHelper();
  double buttonfactor = 0.45;

  String getFormatedDateTime(Map startdate) {
    // String date = DateFormat('dd.MM.yy').format(DateTime.parse(startdate));
    // String time = DateFormat.Hm().format(DateTime.parse(startdate));
    EventDate eventdate = EventDate().fromSnapshot(startdate);
    return eventdate.getDate() + "\n" + eventdate.getTime();
  }

  getDeleteDialog(String eid) async {
    return showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(40.0),
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(232, 255, 24, 100),
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              color: const Color.fromARGB(255, 54, 107, 103),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 5,
                  offset: Offset(0, 5), 
                  color: Color.fromARGB(156, 22, 73, 69)
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Text(
                    "Do you really want to delete this Event?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 231, 250, 60),
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter deleteState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            try {
                              fb.deleteDocumentById("events_new", eid);
                              log("Deleted Event!");
                              deleteState(() {
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              log(e.toString());
                            }
                          }, 
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 255, 100))
                          ),
                          child: const Text(
                            "Yes, Delete!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromARGB(156, 9, 31, 29)
                            ),
                          )
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 255, 100))
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromARGB(156, 9, 31, 29)
                            ),
                          )
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.2,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(
                      color: Color.fromARGB(156, 32, 68, 65),
                      width: 2
                    ),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 231, 250, 60),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateEventPage()));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color.fromARGB(156, 32, 68, 65)),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                  const Text(
                    "Add Event",
                    style: TextStyle(
                      color: Color.fromARGB(156, 32, 68, 65),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ]
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        StreamBuilder<QuerySnapshot>(
            stream: db.collection("events_new").snapshots(),
            builder: (context, snapshot) {
              List<Widget> children = <Widget>[];
              if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Stack trace: ${snapshot.stackTrace}'),
                  ),
                ];
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    children = const <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Awaiting Events...'),
                      )
                    ];
                    break;
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      for (int i = 0; i < snapshot.data!.size; i++) {
                        DocumentSnapshot event = snapshot.data!.docs[i];
                        children.add(
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.1,
                            child: ElevatedButton(
                              onLongPress: () {
                                getDeleteDialog(event['eid']);
                              },
                              onPressed: () {
                                Event eventT = Event(
                                  event['eid'],
                                  user.uid,
                                  event['name'],
                                  EventDate.fromEventDate(
                                    event['startdate']["date"], 
                                    event['startdate']["time"], 
                                  ),
                                  EventDate.fromEventDate(
                                    event['enddate']["date"], 
                                    event['enddate']["time"],
                                  ),
                                  event['maxNumParticipants'], 
                                  event['participants'],
                                  event['generatedParticipants'], 
                                );
                                eventT.setStarted(event["started"]);
                                log(eventT.toString());
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewEventPage(event: eventT,)));
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(
                                      color: Color.fromARGB(255, 212, 233, 20),
                                      width: 2
                                    ),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromRGBO(49, 98, 94, 50),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    getFormatedDateTime(event["startdate"]),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 239, 255, 100),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.04,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Color.fromARGB(255, 212, 233, 20),
                                          width: 2,
                                        ),
                                      )
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.02,
                                  ),
                                  Flexible(
                                    child: Text(
                                      event["name"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 239, 255, 100),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                        );
                      }
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.58,
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Image.asset(
                              "lib/assets/Standing_Runner.png",
                              width: MediaQuery.of(context).size.height*0.1
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            const Text(
                              "Looks pretty empty here!\n",
                              style: TextStyle(
                                color: Color.fromARGB(255, 231, 250, 60),
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    break;
                  default:
                    log("What happend here? Events Overview");
                }
              }

              if (children.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.58,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Image.asset(
                        "lib/assets/Standing_Runner.png",
                        width: MediaQuery.of(context).size.height*0.1
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      const Text(
                        "Looks pretty empty here!\n",
                        style: TextStyle(
                          color: Color.fromARGB(255, 231, 250, 60),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height*0.58,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: children,
                    ),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
