import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/event.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/screens/createEventScreen.dart';
import 'package:demo_app/screens/viewEventScreen.dart';
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
        // TODO: View when no event exists
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
                              onPressed: () {
                                List<dynamic> participants = [];
                                if (!event['generatedParticipants']) {
                                  for (dynamic p in event["participants"]) {
                                    participants.add(p);
                                  }
                                } else {
                                  for (dynamic p in event["participants"]) {
                                    participants.add(GeneratedParticipant(
                                      p['number'],
                                      EventState.values[p['state']]
                                    ));
                                  }
                                }
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
                                  participants,
                                  event['generatedParticipants'], 
                                );
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
                      return Column(
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
                      );
                    }
                    break;
                  default:
                    log("What happend here? Events Overview");
                }
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height*0.6,
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
            },
          ),
      ],
    );
  }
}
