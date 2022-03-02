// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/main.dart';
import 'package:event_timing_app/modules/dashboard/models/event.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParticipantCreationPage extends StatefulWidget {
  // String uid = "";
  // Event event;

  ParticipantCreationPage({Key? key}) : super(key: key);
  
  @override 
  _ParticipantCreationPageState createState() => _ParticipantCreationPageState();
}

class _ParticipantCreationPageState extends State<ParticipantCreationPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void showDialog2() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Participant"),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: null
                  ),
                  Form(
                    key: formkey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text("Startnumber:"), // TODO make text more beautiful
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                              items: List<int>.generate(100, (i) => i + 1).map<DropdownMenuItem<String>>((int value) {
                                return DropdownMenuItem<String>(child: Text(value.toString()), value: value.toString());
                              }).toList(),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: null
                        ),
                        Row(
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0),
                              child: null
                            ),
                            DropdownButton<String>(
                              value: "Diverse",
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
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: null
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "E-Mail"),
                          validator: null, // TODO
                          onChanged: (val) => email = val,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: null
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              Participant participant = Participant(
                                firstName!, 
                                secondName!, 
                                sex, 
                                int.parse(dropdownvalue2), 
                                email, 
                                int.parse(dropdownvalue3));
                              db.collection("participants").add(participant.toJSON());
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
                            }
                          }, 
                          child: const Text("Create")
                        ),
                      ],
                    )
                  )
                ],
              ),
            )
          ),
        );
      }
    );

  }




  final db = FirebaseFirestore.instance;
  
  String uid = "CHz78WQ60tbFYJDHMvT5tGba4dx2";

  Sex sex = Sex.Diverse;
  String dropdownvalue = "Diverse";
  String dropdownvalue2 = "18";
  String dropdownvalue3 = "1";

  String? firstName;
  String? secondName;
  String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event Participants"),
        // automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: null
            ),
            Form(
              key: formkey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Startnumber:"), // TODO make text more beautiful
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                        items: List<int>.generate(100, (i) => i + 1).map<DropdownMenuItem<String>>((int value) {
                          return DropdownMenuItem<String>(child: Text(value.toString()), value: value.toString());
                        }).toList(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: null
                      ),
                      DropdownButton<String>(
                        value: "Diverse",
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "E-Mail"),
                    validator: null, // TODO
                    onChanged: (val) => email = val,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        Participant participant = Participant(
                          firstName!, 
                          secondName!, 
                          sex, 
                          int.parse(dropdownvalue2), 
                          email, 
                          int.parse(dropdownvalue3));
                        db.collection("participants").add(participant.toJSON());
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
                      }
                    }, 
                    child: const Text("Create")
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}


