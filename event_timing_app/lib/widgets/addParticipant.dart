// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/main.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddParticipant extends StatefulWidget {
  const AddParticipant({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddParticipantState();

}

class _AddParticipantState extends State<AddParticipant> {

  GlobalKey<FormState> formKeyP = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;

  String uid = " C1xtw4TSAmyfcIoGH1Km";

  Sex sex = Sex.Diverse;
  String? dropdownvalue = "Male";
  String? dropdownvalue2 = "1";
  String? dropdownvalue3 = "1";

  String? firstName;
  String? secondName;
  String email = "";
  
  @override
  Widget build(BuildContext context) {
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
                                    }
                                  }, 
                                  child: const Text("Add")
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*.03),
                                  child: null
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, 
                                  child: const Text("Cancel")
                                ),
                              ],
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

class UpdateParticipant extends StatefulWidget {
  Map<String, dynamic> ds;
  UpdateParticipant({Key? key, required this.ds}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpdateParticipantState(
    ds["firstName"].toString(), 
    ds["secondName"].toString(),
    ds["sex"].toString(),
    ds["age"].toString(),
    ds["email"].toString(),
    ds["startNum"].toString(),
  );

}

class _UpdateParticipantState extends State<UpdateParticipant> {
  GlobalKey<FormState> formKeyP = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;

  String uid = " C1xtw4TSAmyfcIoGH1Km";

  Sex sex = Sex.None;
  String? dropdownvalue = "Male";
  String? dropdownvalue2 = "1";
  String? dropdownvalue3 = "1";

  String? firstName;
  String? secondName;
  String email = "";

  _UpdateParticipantState(this.firstName, this.secondName, this.dropdownvalue, this.dropdownvalue2, this.email, this.dropdownvalue3);
  
  @override
  Widget build(BuildContext context) {
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
                                  border: OutlineInputBorder(), labelText: "Firstname"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter The Firstname";
                                }
                                return null;
                              },
                              initialValue: firstName,
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
                              initialValue: secondName,
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
                              initialValue: email,
                              onChanged: (val) => email = val,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.005),
                              child: null
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                      db.collection("participants").doc(uid).update(participant.toJSON()); // TODO change uid
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
                                    }
                                  }, 
                                  child: const Text("Update")
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*.03),
                                  child: null
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }, 
                                  child: const Text("Cancel")
                                ),
                              ],
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




