// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/main.dart';
import 'package:event_timing_app/modules/dashboard/models/event.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:flutter/material.dart';

class ParticipantsPage extends StatefulWidget {
  // String uid = "";
  Event event;

  ParticipantsPage({Key? key, required this.event}) : super(key: key);
  
  @override 
  _ParticipantsPageState createState() => _ParticipantsPageState(event: event);
}

class _ParticipantsPageState extends State<ParticipantsPage> {

  Event event;
  _ParticipantsPageState({Key? key, required this.event});

  final db = FirebaseFirestore.instance;
  String uid = "CHz78WQ60tbFYJDHMvT5tGba4dx2";

  Sex sex = Sex.Diverse;
  String? dropdownvalue;
  String? dropdownvalue2;
  String? dropdownvalue3;

  String? firstName;
  String? secondName;
  String email = "";

  void showDialog3() {
    GlobalKey<FormState> formKeyP = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Participant"),
              content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Form(
                        key: formKeyP,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text("Startnumber:"),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                                  child: null
                                ), 
                                DropdownButton<String>(
                                  value: dropdownvalue3,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                        dropdownvalue3 = newValue!;
                                    });
                                  },
                                  // TODO adapt on maxNUmParticipants and already given numbers
                                  items: List<int>.generate(event.getMaxNumParticipants(), (i) => i + 1).map<DropdownMenuItem<String>>((int value) {
                                    return DropdownMenuItem<String>(child: Text(value.toString()), value: value.toString());
                                  }).toList(),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), labelText: "Firstname"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter The Firstname";
                                }
                                return null;
                              },
                              onChanged: (val) => firstName = val,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), labelText: "Secondname"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter The Secondname";
                                }
                                return null;
                              },
                              onChanged: (val) => secondName = val,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                DropdownButton<String>(
                                  value: dropdownvalue,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      if (newValue == "Female") {
                                        sex = Sex.Female;
                                      } else if (newValue == "Male") {
                                        sex = Sex.Male;
                                      } else if (newValue == "Diverse") {
                                        sex = Sex.Diverse;
                                      } else {
                                        sex =  Sex.None;
                                      }
                                      dropdownvalue = newValue!;
                                    });
                                  },
                                  items: <String>['Male', 'Female', 'Diverse'].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(child: Text(value), value: value);
                                  }).toList(),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.03),
                                  child: null
                                ),
                                DropdownButton<String>(
                                  value: dropdownvalue2,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                        dropdownvalue2 = newValue!;
                                    });
                                  },
                                  items: List<int>.generate(100, (i) => i + 1).map<DropdownMenuItem<String>>((int value) {
                                    return DropdownMenuItem<String>(child: Text(value.toString()), value: value.toString());
                                  }).toList(),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), labelText: "E-Mail (optional)"),
                              validator: null, // TODO
                              onChanged: (val) => email = val,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (formKeyP.currentState!.validate()) {
                                  Participant participant = Participant(
                                    firstName!, 
                                    secondName!, 
                                    sex, 
                                    int.parse(dropdownvalue2!), 
                                    email, 
                                    int.parse(dropdownvalue3!));
                                  db.collection("participants").add(participant.toJSON());
                                  event.addParticipant(participant);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ParticipantsPage(event: event,)));
                                }
                              }, 
                              child: const Text("Add")
                            ),
                          ],
                        )
                      )
                    ],
                  ),
              ),
            );
          }
        );
        
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Participants"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // TODO save the event finally with the created participants and go to Event Overview Page
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
            },
            icon: Icon(Icons.check)
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("participants").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];   // TODO hier wird data received
                return Container(
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Text(ds['startNum'].toString()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                          child: null
                        ),
                        Text(ds['firstName']),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                          child: null
                        ),
                        Text(ds['secondName']),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.01),
                          child: null
                        ),
                        Text('(' + ds['sex'] + ')'),
                      ],
                    ),
                    onLongPress: () {
                      // TODO == delete
                      db.collection("participants").doc(ds.id).delete();
                    },
                    onTap:  () {
                      // TODO == Update
                      db.collection("participants").doc(ds.id).update({"firstName": "firstName geupdated"});
                    },
                  )
                );
              }
            );
          } else if (snapshot.hasError) {
            return const CircularProgressIndicator();
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showDialog3,
        child: Icon(Icons.add),
      ),

    );
  }
}

// var tmp = Row(
//   children: <Widget>[
//     Text(ds['startNum']),
//     Text(ds['firstName']),
//     Text(ds['secondName']),
//     Text('(' + ds['sex'] + ')'),
//   ],
// );