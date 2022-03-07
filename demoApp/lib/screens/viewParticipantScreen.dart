// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/widgets/events_overview.dart';
import 'package:demo_app/widgets/profil_view.dart';
import 'package:demo_app/widgets/timer_view.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewParticipantPage extends StatefulWidget {
  CreatedParticipant participant;

  ViewParticipantPage({Key? key, required this.participant}) : super(key: key);

  @override
  _ViewParticipantPageState createState() => _ViewParticipantPageState(participant: participant);
}

class _ViewParticipantPageState extends State<ViewParticipantPage> {
  CreatedParticipant participant;
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();
  double legendsize = 0.3;
  double legendsize2 = 0.2;

  var items = [    
    EventState.dns.stateToString(),
    EventState.dnf.stateToString(),
    EventState.running.stateToString(),
    EventState.finished.stateToString(),
  ];

  List<Color> stateColors = [
    Colors.grey, 
    const Color.fromRGBO(211, 47, 47, 1),
    const Color.fromRGBO(66, 165, 245, 1),
    const Color.fromARGB(255, 231, 250, 60)
  ];

  int eventStateFromString(String name) {
    switch(name) {
      case "DNS":
        return 0;
      case "DNF":
        return 1;
      case "RUNNING":
        return 2;
      case "FINISHED":
        return 3;
      default: 
        return -1; 
    }
  }

  getSexAsLetter(Sex sex) {
    switch (sex) {
      case Sex.male: return "Male";
      case Sex.female: return "Female";
      case Sex.diverse: return "Diverse";
      case Sex.none: return "None";
      default: return "...";
    }
  }

  // ignore: unused_element
  _ViewParticipantPageState({Key? key, required this.participant});
  

  TextStyle getTextStyle(double fontSize) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: const Color.fromARGB(255, 231, 250, 60),
      shadows: const [
        Shadow(
          offset: Offset(2,2),
          blurRadius: 3.0,
          color: Color.fromARGB(156, 32, 68, 65),
        ),
      ]
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Event Timer",
              style: TextStyle(
                color: Color.fromARGB(255, 239, 255, 100)
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.height*0.01,
            ),
            Image.asset(
              "lib/assets/runner.png",
              width: MediaQuery.of(context).size.height*0.05
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(49, 98, 94, 50),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 239, 255, 100)
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // TODO: Add an Alert Dialog that asks for delete
              print("Deleted Event");
            },
            icon: Icon(
              Icons.delete_sweep,
              color: Colors.red[800],
              size: 30,
            )
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width*0.7,
                height: MediaQuery.of(context).size.width*0.1,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(49, 98, 94, 100),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10),),
                  color: const Color.fromARGB(255, 231, 250, 60),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 7,
                      spreadRadius: 5,
                      offset: Offset(0, 5), 
                      color: Color.fromARGB(156, 9, 31, 29)
                    ),
                  ],
                ),
                // color: const Color.fromRGBO(232, 255, 24, 100),
                child: Center(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: db.collection("userprofiles").snapshots(),
                    builder: (context, snapshot) {
                      String name = "...";
                      if (snapshot.hasData) {
                        for (int i = 0; i < snapshot.data!.size; i++) {
                          DocumentSnapshot ds = snapshot.data!.docs[i];
                          if (ds["uid"] == user.uid) {
                            name = ds['firstname'] + " " + ds["secondname"];
                          }
                        }
                      }
                      return Text(
                        "Welcom " + name,
                        style: const TextStyle(
                          color: Color.fromRGBO(49, 98, 94, 50),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  )
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(232, 255, 24, 100),
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                color: const Color.fromARGB(156, 58, 114, 109),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 7,
                    spreadRadius: 5,
                    offset: Offset(0, 5), 
                    color: Color.fromARGB(156, 9, 31, 29)
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(232, 255, 24, 100),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      color: const Color.fromARGB(156, 54, 107, 103),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 5,
                          offset: Offset(0, 5), 
                          color: Color.fromARGB(156, 22, 73, 69)
                        ),
                      ],
                    ),
                    child: Text(
                      participant.getFirstname() + "\n" + participant.getSecondname(),
                      style: getTextStyle(25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.04,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(156, 54, 107, 103),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15.0), 
                        bottomRight: Radius.circular(15.0)
                      ),
                      color: const Color.fromARGB(255, 232, 255, 24),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 5,
                          offset: Offset(0, 5), 
                          color: Color.fromARGB(156, 22, 73, 69)
                        ),
                      ],
                    ),
                    child: Text(
                      "*" + participant.getBirthDate(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromRGBO(49, 98, 94, 50),
                      ),
                    )
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.1,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.32,
                            height: MediaQuery.of(context).size.height * 0.12,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(232, 255, 24, 100),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                              color: Color.fromARGB(156, 54, 107, 103),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 7,
                                  spreadRadius: 5,
                                  offset: Offset(0, 5), 
                                  color: Color.fromARGB(156, 22, 73, 69)
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Gender",
                                  style: getTextStyle(17),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  getSexAsLetter(participant.getSex()),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 231, 250, 60),
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2,2),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(156, 32, 68, 65),
                                      ),
                                    ]
                                  ),
                                ),
                              ],
                            )
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.32,
                            height: MediaQuery.of(context).size.height * 0.12,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(232, 255, 24, 100),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                              color: Color.fromARGB(156, 54, 107, 103),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 7,
                                  spreadRadius: 5,
                                  offset: Offset(0, 5), 
                                  color: Color.fromARGB(156, 22, 73, 69)
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Age",
                                  style: getTextStyle(17),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  participant.getAge().toString(),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 231, 250, 60),
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2,2),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(156, 32, 68, 65),
                                      ),
                                    ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.05,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(232, 255, 24, 100),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      color: const Color.fromARGB(156, 54, 107, 103),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 5,
                          offset: Offset(0, 5), 
                          color: Color.fromARGB(156, 22, 73, 69)
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Text(
                          "Contact:",
                          style: getTextStyle(15),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Text(
                          participant.getEmail(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 231, 250, 60),
                            shadows: [
                              Shadow(
                                offset: Offset(2,2),
                                blurRadius: 3.0,
                                color: Color.fromARGB(156, 32, 68, 65),
                              ),
                            ]
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    )
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.275,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(232, 255, 24, 100),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      color: const Color.fromARGB(156, 54, 107, 103),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 5,
                          offset: Offset(0, 5), 
                          color: Color.fromARGB(156, 22, 73, 69)
                        ),
                      ],
                    ),
                    child: Text("PArticipated Events"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }

}

