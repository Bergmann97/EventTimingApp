import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/screens/createParticipantScreen.dart';
import 'package:demo_app/screens/viewParticipantScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';


class ParticipantView extends StatefulWidget {
  const ParticipantView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ParticipantViewState();

}

class _ParticipantViewState extends State<ParticipantView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  DocumentReference? docRef;
  FirebaseHelper fb = FirebaseHelper();

  getSexAsLetter(Sex sex) {
    switch (sex) {
      case Sex.male: return "M";
      case Sex.female: return "F";
      case Sex.diverse: return "D";
      case Sex.none: return "N";
      default: return "...";
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

  Participant getParticipantFromSnapshot(participant) {
    return Participant(
      participant['uid'],
      stringToSex(participant['sex']), 
      participant['firstname'], 
      participant['secondname'], 
      participant["birthdate"], 
      participant['email'], 
    );
  }

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

  getFormatedParticipant(participant) {
    Participant p = getParticipantFromSnapshot(participant);

    return p.getFirstname() + " " + p.getSecondname() + 
            " (" + getSexAsLetter(p.getSex()) + "/" 
            + p.getAge().toString() + ")";
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateParticipantPage()));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color.fromARGB(156, 32, 68, 65)),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                  const Text(
                    "Add Participant",
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
        Center(
          child: Text(
            "Your Participants",
            style: getTextStyle(20),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        StreamBuilder<QuerySnapshot>(
            stream: db.collection("participants_new").snapshots(),
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
                        DocumentSnapshot participant = snapshot.data!.docs[i];
                        children.add(
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.05,
                            child: ElevatedButton(
                              onPressed: () {
                                Participant p = getParticipantFromSnapshot(participant);
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewParticipantPage(participant: p)));
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
                              child: Text(
                                getFormatedParticipant(participant),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 239, 255, 100),
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
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
                    log("What happend here? participants Overview");
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
