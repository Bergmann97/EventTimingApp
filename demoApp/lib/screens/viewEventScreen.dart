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

class ViewEventPage extends StatefulWidget {
  Event event;

  ViewEventPage({Key? key, required this.event}) : super(key: key);

  @override
  _ViewEventPageState createState() => _ViewEventPageState(event: event);
}

class _ViewEventPageState extends State<ViewEventPage> {
  Event event;
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();
  double legendsize = 0.3;
  double legendsize2 = 0.2;

  var dropdownvalue; 
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

  // ignore: unused_element
  _ViewEventPageState({Key? key, required this.event});
  

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

  getAlertDNFParticipantDialog(int i) {
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
                const Text(
                  "To what state do you want to set the person?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 231, 250, 60),
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter dropDownState) {
                    return DropdownButton<String>(
                      value: dropdownvalue,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color.fromARGB(255, 231, 250, 60),
                      ),
                      dropdownColor: const Color.fromARGB(255, 32, 63, 60),
                      borderRadius: BorderRadius.circular(15.0),
                      items: items.map((String item) {
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
                          print(dropdownvalue);
                        });
                      },
                    );
                  }
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          event.getParticipants()[i].setState(EventState.values[items.indexOf(dropdownvalue!)]);
                          fb.updateDocumentById("events_new", event.getEid(), event.toJSON());
                        });
                        print("state changed");
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    TextButton(
                      onPressed: () {
                        print("no change");
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

  createParticipantDots() {
    List<Widget> children = [];
    if (event.getMaxNumParticipants() > 0) {
      for (int i = 0; i < event.getMaxNumParticipants(); i++) {
        children.add(
          Container(
            width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.width * 0.09,
            alignment: Alignment.center,
            child: TextButton(
                  onPressed: () {
                    // TODO:_ go to edit page -> Create Oage?
                    print("Pressed Participant");
                  }, 
                  onLongPress: () {
                    setState(() {
                      dropdownvalue = EventState.values[event.getParticipants()[i].getState()].stateToString();
                      if (event.getParticipants()[i].getState() != EventState.dnf.index) {
                        getAlertDNFParticipantDialog(i);
                      } else {
                        print("no change");
                      }
                    });
                  },
                  child: Center(
                    child:Text(
                      (i+1).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (i+1) < 10 ? 14 : ((i+1) < 100 ? 13 : 9),
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
                      stateColors[event.getParticipants()[i].getState()]
                    ),
                  ),
                ),
          ),
        );
      }
    }
    return children;
  }

  Widget getParticipantView(bool generated) {
    if (generated) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.37,
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
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              "Participants (" + event.getMaxNumParticipants().toString() + ")",
              style: getTextStyle(20),
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
              width: MediaQuery.of(context).size.width * 0.7,
              child: Wrap(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * legendsize2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                          "  DNS  ",
                          style: getTextStyle(15),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * legendsize,
                    child: Row(
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * legendsize2,
                    child: Row(
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * legendsize,
                    child: Row(
                      children: [
                        Icon(
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
      return Text("create some");
    }
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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        event.getName(),
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
                              const Icon(
                                Icons.event,
                                color: Color.fromARGB(255, 231, 250, 60),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                              Text(
                                event.getStartdate().getDate(),
                                style: getTextStyle(17),
                              ),
                              Text(
                                event.getStartdate().getTime(),
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
                              const Icon(
                                Icons.golf_course,
                                color: Color.fromARGB(255, 231, 250, 60),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                              Text(
                                event.getEnddate().getDate(),
                                style: getTextStyle(17),
                              ),
                              Text(
                                event.getEnddate().getTime(),
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
                  getParticipantView(event.isGenerated()),
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
                  onPressed: () {
                    // TODO:_ go to edit page -> Create Oage?
                    print("Edit Event");
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
                      const Color.fromARGB(255, 231, 250, 60),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO
          print("Add Participant");
        },
        child: const Icon(
          Icons.add, 
          color: Color.fromRGBO(49, 98, 94, 100),
          size: 40,
        ),
        backgroundColor: const Color.fromARGB(255, 231, 250, 60),
      ),
    );
  }

}

