import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/screens/createEventScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String getFormatedDateTime(String startdate) {
    String date = DateFormat('dd.MM.yy').format(DateTime.parse(startdate));
    String time = DateFormat.Hm().format(DateTime.parse(startdate));

    return date + "\n" + time;
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
                // TODO: Open Create Event Page
                print("ADD EVENT");
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
                              onPressed: () {
                                print(event['eid']);
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    getFormatedDateTime(event["startdate"]),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(156, 32, 68, 65),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.04,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Color.fromARGB(156, 32, 68, 65),
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
                                        color: Color.fromARGB(156, 32, 68, 65),
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
                    print("This should not happen");
                }
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height*0.5,
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
