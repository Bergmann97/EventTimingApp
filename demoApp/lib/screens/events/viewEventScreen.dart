// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/screens/events/editEventScreen.dart';
import 'package:demo_app/screens/participants/createParticipantScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

// ignore: must_be_immutable
class ViewEventPage extends StatefulWidget {
  Event event;

  ViewEventPage({Key? key, required this.event}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ViewEventPageState createState() => _ViewEventPageState(event: event);
}

class _ViewEventPageState extends State<ViewEventPage> {
  Event event;
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();
  double legendsize = 0.2;
  double legendsize2 = 0.2;

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();

  bool _deleted = false;
  bool _marked = false;
  List<String> markedUsers = [];
  String dropdownvalue = "RUNNING"; 

  List<String> items = [    
    EventState.none.stateToString(),
    EventState.dns.stateToString(),
    // EventState.dnf.stateToString(),
    EventState.running.stateToString(),
    EventState.finished.stateToString(),
  ];

  List<String> startedItems = [
    EventState.dnf.stateToString(),
    EventState.running.stateToString(),
  ];

  List<Color> stateColors = [
    Colors.grey,
    const Color.fromARGB(255, 255, 208, 0),
    const Color.fromRGBO(211, 47, 47, 1),
    const Color.fromRGBO(66, 165, 245, 1),
    const Color.fromARGB(255, 231, 250, 60),
  ];

  // TODO: Anzeige der States unter participants responsive bekommen

  int eventStateFromString(String name) {
    switch(name) {
      case "DNS":
        return 1;
      case "DNF":
        return 2;
      case "RUNNING":
        return 3;
      case "FINISHED":
        return 4;
      case "NONE":
        return 0;
      default: 
        return -1; 
    }
  }

  // ignore: unused_element
  _ViewEventPageState({Key? key, required this.event});
  
  bool canAddParticipant() {
    if (event.getMaxNumParticipants() - event.getParticipants().length == 0) {
      return false;
    } else if (event.getMaxNumParticipants() - event.getParticipants().length - markedUsers.length == 0) { 
      return false;
    } else {
      return true;
    }
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
                              fb.deleteDocumentById("events_new", event.getEid());
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

  getRemoveDialog(String pid) async {
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
            height: MediaQuery.of(context).size.height * 0.17,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Text(
                    "Do you want to remove this participant from the event? (not undoable)",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        try {
                          List parts = event.getParticipants();
                          setState(() {
                            parts.removeWhere((element) => element['uid'] == pid);
                            event.setParticipants(parts);
                            fb.updateDocumentById(
                              "events_new", 
                              event.getEid(), 
                              {
                                'participants': parts,
                              }
                            );
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
                        "Yes, Remove!",
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
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  getAlertDNFParticipantDialog(Map participant) {
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
            height: MediaQuery.of(context).size.height * 0.21,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: const Text(
                    "To what state do you want to set the person?",
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
                event.isStarted() && participant["state"] == EventState.running.index ?
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter dropDownState) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: DropdownButton<String>(
                          value: dropdownvalue,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color.fromARGB(255, 231, 250, 60),
                          ),
                          dropdownColor: const Color.fromARGB(255, 32, 63, 60),
                          borderRadius: BorderRadius.circular(15.0),
                          items: startedItems.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: stateColors[eventStateFromString(item)],
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.03
                                  ),
                                  Text(
                                    item,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 250, 60),
                                      fontWeight: item == dropdownvalue ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                dropDownState(() {
                                  dropdownvalue = item;
                                });
                              },
                            );
                          }).toList(),
                          
                          onChanged: (String? newValue) { 
                            dropDownState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                      );
                    }
                  ) :
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter dropDownState) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: DropdownButton<String>(
                          value: dropdownvalue,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color.fromARGB(255, 231, 250, 60),
                          ),
                          dropdownColor: const Color.fromARGB(255, 32, 63, 60),
                          borderRadius: BorderRadius.circular(15.0),
                          items: items.map((String item2) {
                            return DropdownMenuItem(
                              value: item2,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: stateColors[eventStateFromString(item2)],
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.03
                                  ),
                                  Text(
                                    item2,
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 231, 250, 60),
                                      fontWeight: item2 == dropdownvalue ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                dropDownState(() {
                                  dropdownvalue = item2;
                                });
                              },
                            );
                          }).toList(),
                          
                          onChanged: (String? newValue) { 
                            dropDownState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                      );
                    }
                  ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              var t = event.getParticipants().indexWhere((element) => element['number'] == participant['number']);
                              log("1234");
                              log(eventStateFromString(dropdownvalue).toString());
                              event.getParticipants()[t]["state"] = eventStateFromString(dropdownvalue);
                              participant['state'] = eventStateFromString(dropdownvalue);
                              log(event.getParticipants().toString());
                              FirebaseHelper f = FirebaseHelper();
                              f.updateDocumentById(
                                "events_new", 
                                event.getEid(), 
                                {'participants': event.getParticipants()}
                              );
                            });
                            log("State changed!");
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewEventPage(event: event,)));
                            Navigator.pop(context);
                          }, 
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 255, 100))
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromARGB(156, 9, 31, 29)
                            ),
                          )
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextButton(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  List<Widget> createParticipantDots() {
    List<Widget> children = [];
    if (event.getMaxNumParticipants() > 0) {
      for (Map participant in event.getParticipants()) {
        children.add(
          Container(
            width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.width * 0.09,
            alignment: Alignment.center,
            child: TextButton(
                  onPressed: () {
                    log("Pressed Participant!");
                  }, 
                  // TODO: only allow if (event started and participant has running status) or event did not start yet
                  onLongPress: () {
                    setState(() {
                      dropdownvalue = EventState.values[event.getParticipants()[participant["number"]-1]["state"]].stateToString();
                      getAlertDNFParticipantDialog(participant);
                    });
                  },
                  child: Center(
                    child:Text(
                      participant["number"].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: participant["number"] < 10 ? 14 : (participant["number"] < 100 ? 13 : 9),
                        color: const Color.fromARGB(156, 9, 31, 29)
                      ),
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
                      stateColors[participant["state"]]
                    ),
                  ),
                ),
          ),
        );
      }
    }
    return children;
  }

  Map<String, dynamic> checkParticipantInEvent(Map<String, dynamic> data) {
    for (var p in event.getParticipants()) {
      // log(p.toString());
      if (p['uid'] == data['uid']) {
        return {
          'found': true, 
          'participant': p
        };
      }
    }
    return {
      'found': false, 
      'participant': null
    };
  }

  String getSexAsLetter(String sex) {
    switch (sex) {
      case 'male': return "M";
      case 'female': return "F";
      case 'diverse': return "D";
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

  int getAge(Map p){
    var now = DateTime.now();
    var birth = DateTime(
      int.parse(p['birthdate'].split(".")[2]),
      int.parse(p['birthdate'].split(".")[1]),
      int.parse(p['birthdate'].split(".")[0]),
    );

    if ((now.month < birth.month) || (now.month == birth.month && now.day < birth.day)) {
      return now.year-birth.year-1;
    } else {
      return now.year-birth.year;
    }
  }

  String getFormatedParticipant(Map p) {
    return p['firstname'] + " " + p['secondname'];
  }

  Widget createParticipantsList() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter removeState) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StreamBuilder<QuerySnapshot>(
            stream: db.collection("participants_new").snapshots(),
              builder: (context, snapshot) {
                List<Widget> children = [];
                if (snapshot.hasData) {
                  for (DocumentSnapshot data in snapshot.data!.docs) {
                    Map result = checkParticipantInEvent(data.data() as Map<String,dynamic>);
                    if (result['found']) {
                      children.add(
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: ElevatedButton(
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
                            onLongPress: event.isStarted() ? null : 
                              () {
                                removeState(() {
                                  log((data.data()! as Map)['firstname']);
                                  getRemoveDialog((data.data()! as Map)['uid']);
                                });
                              }, 
                            onPressed: event.isStarted() && result['participant']['state'] != EventState.running.index ? 
                              null : 
                              () {
                                // TODO: should only be possible if state is not DNF
                                removeState(() {
                                  // TODO: apply changes also in result list
                                  log(result['participant']["number"].toString());
                                  int t = event.getParticipants().indexWhere((element) => element['number'] == result['participant']["number"]);
                                  log(event.getParticipants()[t].toString());
                                  dropdownvalue = EventState.values[event.getParticipants()[t]["state"]].stateToString();
                                  getAlertDNFParticipantDialog(result['participant']);
                                });
                              },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                  width: MediaQuery.of(context).size.height * 0.03,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: stateColors[result['participant']["state"]],
                                    border: Border.all(
                                      color: const Color.fromARGB(156, 32, 68, 65),
                                      width: 2,
                                    )
                                  ),
                                  child: Text(
                                    result['participant']['number'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: result['participant']['number'] < 10 ? 14 : (result['participant']['number'] < 100 ? 13 : 9),
                                      color: const Color.fromARGB(156, 9, 31, 29),
                                      // color: Colors.white
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.03,
                                ),
                                Flexible(
                                  child: Text(
                                    getFormatedParticipant(data.data() as Map),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),                            
                              ],
                            )
                          ),
                        )
                      );
                    }
                  }
                }

                return Wrap(
                  // spacing: 8.0,
                  // runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: children,
                );
              }
          ),
        );
      }
    );
  }

  bool isEventParticipant(String pid) {
    List parts = event.getParticipants();
    for (var p in parts) {
      if (p['uid'] == pid) {
        return true;
      }
    }
    return false;
  }

  int getNextNumber() {
    int number = 1;
    while (number <= event.getMaxNumParticipants()) {
      if (event.getParticipants().indexWhere((element) => element['number'] == number) == -1) {
        return number;
      } else {
        number++;
      }
    }
    return -1;
  }

  addParticipantToEvent() {
    List parts = event.getParticipants();
    log(parts.toString());
    log(parts.length.toString());
    for (String newP in markedUsers) {
      if (parts.length < event.getMaxNumParticipants()) {
        parts.add(
          {
            'uid': newP,
            'state': 0,
            'number': getNextNumber()
          }
        );
      }
    }
    log(parts.toString());
    log(parts.length.toString());

    fb.updateDocumentById(
      "events_new", 
      event.getEid(), 
      {
        'participants': parts
      }
    );
  }

  Widget getParticipantView() {
    log("Participants Generated: " + event.isGenerated().toString());
    if (event.isGenerated()) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.37,
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
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.035,
              child: Text(
                "Participants (" + event.getMaxNumParticipants().toString() + ")",
                style: getTextStyle(20),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.23,
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 3,
                      runSpacing: 3,
                      children: createParticipantDots()
                    ),
                  ]
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.01,
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.17,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                          "  None  ",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.17,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: stateColors[1],
                          size: 15,
                        ),
                        Text(
                          "  DNS  ",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.14,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.red[700],
                          size: 15,
                        ),
                        Text(
                          "  DNF",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.21,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.blue[400],
                          size: 15,
                        ),
                        Text(
                          "  running  ",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color.fromARGB(255, 231, 250, 60),
                          size: 15,
                        ),
                        Text(
                          "  finished  ",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.37,
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
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                  child: Text(
                    "Participants (" + event.getParticipants().length.toString() + "/" + event.getMaxNumParticipants().toString() + ")",
                    style: getTextStyle(20),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.23,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        createParticipantsList(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ]
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.01,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.17,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.grey,
                              size: 15,
                            ),
                            Text(
                              "  None  ",
                              style: getTextStyle(15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.17,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              color: stateColors[1],
                              size: 15,
                            ),
                            Text(
                              "  DNS  ",
                              style: getTextStyle(15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.14,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.red[700],
                              size: 15,
                            ),
                            Text(
                              "  DNF",
                              style: getTextStyle(15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.21,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.blue[400],
                              size: 15,
                            ),
                            Text(
                              "  running  ",
                              style: getTextStyle(15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.22,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Color.fromARGB(255, 231, 250, 60),
                              size: 15,
                            ),
                            Text(
                              "  finished  ",
                              style: getTextStyle(15),
                            ),
                          ],
                        ),
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
          Positioned(
            bottom: 40,
            right: -5,
            child: ElevatedButton(
              onPressed: event.isStarted() ? null : () {
                log("Add some Participants to Event");
                getParticipantAddDialog();
              },
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 32, 68, 65),
                size: 30.0,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<CircleBorder>(
                  const CircleBorder(
                    side: BorderSide(
                      color: Color.fromARGB(156, 32, 68, 65),
                      width: 2
                    ),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  // const Color.fromARGB(255, 231, 250, 60),
                  event.isStarted() ? const Color.fromARGB(255, 151, 161, 59) : const Color.fromARGB(255, 239, 255, 100)
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(
                    MediaQuery.of(context).size.height * 0.05, 
                    MediaQuery.of(context).size.height * 0.05
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  getParticipantAddDialog() {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          // insetPadding: const EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.63,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter markedState) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.83,
                          height: MediaQuery.of(context).size.height * 0.61,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromRGBO(232, 255, 24, 100),
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                            color: const Color.fromARGB(255, 54, 107, 103),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                              Text(
                                "Add Participants to Event",
                                style: getTextStyle(20),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: const Text(
                                  "Mark participants to add by tap!",
                                  style: TextStyle(
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
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Row(
                                  children: [
                                    const Text(
                                      "You can add at most  ",
                                      style: TextStyle(
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
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      (event.getMaxNumParticipants()-event.getParticipants().length) == 0 ?
                                        "0":
                                        (markedUsers.isEmpty) ? 
                                          (event.getMaxNumParticipants()-event.getParticipants().length).toString() :
                                          (event.getMaxNumParticipants()-event.getParticipants().length-markedUsers.length).toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: (event.getMaxNumParticipants()-event.getParticipants().length) == 0 ?
                                          const Color.fromARGB(255, 255, 0, 0):
                                          (markedUsers.isEmpty) ? 
                                            const Color.fromARGB(255, 231, 250, 60) :
                                            (event.getMaxNumParticipants()-event.getParticipants().length-markedUsers.length) == 0 ?
                                              const Color.fromARGB(255, 255, 0, 0) :
                                              const Color.fromARGB(255, 231, 250, 60),
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(2,2),
                                            blurRadius: 3.0,
                                            color: Color.fromARGB(156, 32, 68, 65),
                                          ),
                                        ]
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Text(
                                      " participants!",
                                      style: TextStyle(
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.67,
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
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
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
                                                child: Text('Awaiting Events...'),
                                              )
                                            ];
                                            break; 
                                          case ConnectionState.active:
                                            log(snapshot.hasData.toString());
                                            if (snapshot.hasData) {
                                              for (var p in snapshot.data!.docs) {
                                                if (!isEventParticipant(p['uid'])) {
                                                  Map participant = (p.data() as Map);
                                                  children.add(
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.6,
                                                      child: ElevatedButton(
                                                        onPressed: !canAddParticipant() && !markedUsers.contains(participant['uid']) ? null : () {
                                                          markedState(() {
                                                            if (markedUsers.contains(participant['uid'])) {
                                                              markedUsers.remove(participant['uid']);
                                                              if (markedUsers.isEmpty) {
                                                                _marked = false;
                                                              }
                                                            } else {
                                                              if (markedUsers.length < event.getMaxNumParticipants()) {
                                                                _marked = true;
                                                                markedUsers.add(participant['uid']);
                                                              }
                                                            }
                                                            log(markedUsers.toString());
                                                          });
                                                        },
                                                        child: Text(getFormatedParticipant(p.data() as Map)),
                                                        style: ButtonStyle(
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                              side: const BorderSide(
                                                                color: Color.fromARGB(255, 212, 233, 20),
                                                                width: 2
                                                              ),
                                                            ),
                                                          ),
                                                          backgroundColor: MaterialStateProperty.all<Color>(
                                                            markedUsers.contains(participant['uid']) ? const Color.fromARGB(255, 151, 167, 14) : const Color.fromRGBO(49, 98, 94, 50),
                                                          ),
                                                        ),
                                                      ),
                                                      // child: Text(p['firstname'])
                                                    )
                                                    
                                                  );
                                                }
                                              }
                                            } else {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.02,
                                                  ),
                                                  Image.asset(
                                                    "lib/assets/Standing_Runner.png",
                                                    width: MediaQuery.of(context).size.height*0.03
                                                  ),
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.02,
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.6,
                                                    child: const Text(
                                                      "You have no Participants left to add to your Event!\nWant to create one?",
                                                      style: TextStyle(
                                                        color: Color.fromARGB(255, 231, 250, 60),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.02,
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.6,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateParticipantPage()));
                                                      },
                                                      child: const Text(
                                                        "Create Participant"
                                                      ),
                                                      style: ButtonStyle(
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
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
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            break;
                                          default:
                                            log("What happend here? Events Overview");
                                        }
                                      }

                                      if (children.isEmpty) {
                                        return Column(
                                          children: [
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.02,
                                            ),
                                            Image.asset(
                                              "lib/assets/Standing_Runner.png",
                                              width: MediaQuery.of(context).size.height*0.03
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.02,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.6,
                                              child: const Text(
                                                "You have no Participants left to add to your Event!\nWant to create one?",
                                                style: TextStyle(
                                                  color: Color.fromARGB(255, 231, 250, 60),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.02,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.6,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateParticipantPage()));
                                                },
                                                child: const Text(
                                                  "Create Participant"
                                                ),
                                                style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
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
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return SizedBox(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 0.0,
                                              alignment: WrapAlignment.center,
                                              children: children,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  ),
                                )
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                              ElevatedButton(
                                onPressed: !_marked ? null : () {
                                  setState(() {
                                    addParticipantToEvent();
                                    markedUsers = [];
                                    _marked = false;
                                    Navigator.of(context).pop();
                                  });
                                }, 
                                style: ButtonStyle(
                                  backgroundColor: _marked ? MaterialStateProperty.all(
                                    const Color.fromARGB(255, 239, 255, 100)
                                  ) :
                                  MaterialStateProperty.all(
                                    const Color.fromARGB(73, 239, 255, 100)
                                  )
                                ),
                                child: const Text(
                                  "Add all marked Participants",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color.fromARGB(156, 9, 31, 29)
                                  ),
                                )
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }
                ),
                Positioned(
                  bottom: 0,
                  right: -25,
                  child: ElevatedButton(
                    onPressed: () {
                      log("Cancel Adding a Participant");
                      setState(() {
                        markedUsers = [];
                        _marked = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Color.fromARGB(255, 231, 250, 60),
                      size: 30.0,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<CircleBorder>(
                        const CircleBorder(
                          side: BorderSide(
                            color: Color.fromARGB(255, 231, 250, 60),
                            width: 2
                          ),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 32, 68, 65),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(
                          MediaQuery.of(context).size.height * 0.05, 
                          MediaQuery.of(context).size.height * 0.05
                        ),
                      ),
                    ),
                  ),
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
    setState(() {
      nameCtrl.text = event.getName();
      startDateCtrl.text = event.getStartdate().getDate();
      startTimeCtrl.text = event.getStartdate().getTime();
      endDateCtrl.text = event.getEnddate().getDate();
      endTimeCtrl.text = event.getEnddate().getTime();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        log("Phone back button pressed");
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
        return false;
      },
      child: Scaffold(
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
              Navigator.of(context).popUntil(ModalRoute.withName("/"));
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
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          nameCtrl.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 231, 250, 60),
                            shadows: [
                              Shadow(
                                offset: Offset(2,2),
                                blurRadius: 3.0,
                                color: Color.fromARGB(156, 32, 68, 65),
                              ),
                            ]
                          ),
                        )
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    SizedBox(
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
                                const Icon(
                                  Icons.event,
                                  color: Color.fromARGB(255, 231, 250, 60),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  startDateCtrl.text,
                                  style: getTextStyle(17),
                                ),
                                Text(
                                  startTimeCtrl.text,
                                  style: getTextStyle(20),
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
                                const Icon(
                                  Icons.golf_course,
                                  color: Color.fromARGB(255, 231, 250, 60),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  endDateCtrl.text,
                                  style: getTextStyle(17),
                                ),
                                Text(
                                  endTimeCtrl.text,
                                  style: getTextStyle(20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    getParticipantView(),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                    onPressed: event.isStarted() ? null : () async {
                      log("Edit Event");

                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(
                          builder: (context) 
                            => EditEventPage(event: event)
                        )
                      );
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
                            "Edit Event",
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
                        event.isStarted() ? const Color.fromARGB(255, 151, 161, 59) : const Color.fromARGB(255, 239, 255, 100)
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

