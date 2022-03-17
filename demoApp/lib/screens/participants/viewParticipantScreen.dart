// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/screens/events/viewEventScreen.dart';
import 'package:demo_app/screens/participants/editParticipantScreen.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

// ignore: must_be_immutable
class ViewParticipantPage extends StatefulWidget {
  Participant participant;

  ViewParticipantPage({Key? key, required this.participant}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ViewParticipantPageState createState() => _ViewParticipantPageState(participant: participant);
}

class _ViewParticipantPageState extends State<ViewParticipantPage> {
  Participant participant;
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();
  double legendsize = 0.3;
  double legendsize2 = 0.2;


  TextEditingController nameCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  TextEditingController ageCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController birthdateCtrl = TextEditingController();


  bool _deleted = false;

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

  Sex stringToSex(String sex) {
    switch (sex) {
      case "male": return Sex.male;
      case "female": return Sex.female;
      case "diverse": return Sex.diverse;
      default: return Sex.none;
    }
  }

  EventState stringToState(String state) {
    switch (state) {
      case "DNS": return EventState.dns;
      case "DNF": return EventState.dnf;
      case "FINISHED": return EventState.finished;
      case "RUNNING": return EventState.running;
      default: return EventState.none;
    }
  }

  Future<Participant> getParticipantFromSnapshot(participant) async {
    return Participant(
      participant['uid'],
      stringToSex(participant['sex']), 
      participant['firstname'], 
      participant['secondname'], 
      participant["birthdate"], 
      participant['email'], 
    );
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

  getDeleteDialog() async {
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
                    "Do you really want to delete this participant?",
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
                              // TODO: check for appearence of participant in events participants list and remove it
                              fb.deleteDocumentById("participants_new", participant.getUID());
                              fb.deleteEventDocsWithParticipant(participant.getUID());
                              log("Deleted Event!");
                              deleteState(() {
                                _deleted = true;
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
  void initState() {
    super.initState();
    nameCtrl.text = participant.getFirstname() + "\n" + participant.getSecondname();
    genderCtrl.text = getSexAsLetter(participant.getSex());
    ageCtrl.text = participant.getAge().toString();
    birthdateCtrl.text = participant.getBirthDate();
    if (participant.getEmail().isEmpty) {
      emailCtrl.text = "not given";
    } else {
      emailCtrl.text = participant.getEmail();
    }
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
            onPressed: () async {
              await getDeleteDialog();
              setState(() {
                if (_deleted) {
                  Navigator.of(context).pop();
                }
              });
            },
            icon: Icon(
              Icons.delete_sweep,
              color: Colors.red[800],
              size: 30,
            )
          )
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, 
            color: Color.fromARGB(255, 239, 255, 100)
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                      nameCtrl.text,
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
                      "*" + birthdateCtrl.text,
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
                                  genderCtrl.text,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
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
                                  ageCtrl.text,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
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
                          emailCtrl.text,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
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
                  Center(
                    child: Text(
                      "Participated Events",
                      style: getTextStyle(17),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.24,
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
                    child: StreamBuilder<QuerySnapshot>(
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
                                  child: Text('Awaiting Participants...'),
                                )
                              ];
                              break;
                            case ConnectionState.active:
                              if (snapshot.hasData) {
                                for (int i = 0; i < snapshot.data!.size; i++) {
                                  DocumentSnapshot event = snapshot.data!.docs[i];
                                  List parts = event['participants'];
                                  if (parts.contains(participant.getUID())) {
                                    children.add(
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.7,
                                        height: MediaQuery.of(context).size.height*0.05,
                                        child: ElevatedButton(
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
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewEventPage(event: eventT,)));
                                            // CreatedParticipant p = getParticipantFromSnapshot(participant);
                                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewParticipantPage(participant: p)));
                                          },
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                                side: const BorderSide(
                                                  color: Color.fromARGB(255, 212, 233, 20),
                                                  width: 1
                                                ),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all<Color>(
                                              const Color.fromRGBO(49, 98, 94, 50),
                                            ),
                                          ),
                                          child: Text(event['name'])
                                        )
                                      )
                                    );
                                  }
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
                              log("What happend here? View Participant Screen!");
                          }
                        }
                        return Container(
                          height: MediaQuery.of(context).size.height*0.22,
                          alignment: Alignment.topCenter,
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
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.05,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    log("Edit Participant!");
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) 
                          => EditParticipantPage(participant: participant)
                      )
                    );
                  });
                }, 
                child: Center(
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Color.fromARGB(156, 32, 68, 65),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      const Text(
                        "Edit Participant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color.fromARGB(156, 9, 31, 29)
                        ),
                      ),
                    ],
                  ),
                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

}

