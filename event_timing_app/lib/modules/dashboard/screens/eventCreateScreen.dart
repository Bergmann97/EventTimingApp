// import 'package:flutter/cupertino.dart';

// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_timing_app/main.dart';
import 'package:event_timing_app/modules/dashboard/models/event.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:event_timing_app/modules/dashboard/screens/createParticipantsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {

  EventPage({Key? key}) : super(key: key);

  @override 
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  String uid = "CHz78WQ60tbFYJDHMvT5tGba4dx2";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();


  String? eventName;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  int? maxNumParticipants;

  String _buttonLabel = "Create";

  final db = FirebaseFirestore.instance;

  int _value = 1;

  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();

  // TODO

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: null
            ),
            Form(
              key: formkey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Event Title"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Event Title";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      eventName = val;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  Row(
                    children: <Widget>[
                      // Expanded(
                      //   child: TextFormField(
                      //     readOnly: true,
                      //     controller: startDateCtrl,
                      //     decoration: const InputDecoration(
                      //       labelText: 'Start Date',
                      //       //filled: true,
                      //       icon: Icon(Icons.calendar_today),
                      //       labelStyle:
                      //           TextStyle(decorationStyle: TextDecorationStyle.solid),
                      //     ),
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return "Please Enter Date";
                      //       }
                      //       return null;
                      //     },
                      //     onTap: () async {
                      //       DateTime? date = DateTime(1900);
                      //       FocusScope.of(context).requestFocus(FocusNode());
                      //       date = await showDatePicker(
                      //         context: context, 
                      //         initialDate: DateTime.now(), 
                      //         firstDate: DateTime(1900, 1, 1, 1, 1), 
                      //         lastDate: DateTime(2200),
                      //       );
                      //       DateFormat formatter = DateFormat("dd.MM.yyy");
                      //       startDateCtrl.text = formatter.format(date!);
                      //     },
                      //     onChanged: (val) {
                      //       startDate = val;
                      //     },
                      //   ),
                      // ),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: endDateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            //filled: true,
                            icon: Icon(Icons.calendar_today),
                            labelStyle:
                                TextStyle(decorationStyle: TextDecorationStyle.solid),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Date";
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? date = DateTime(1900);
                            FocusScope.of(context).requestFocus(FocusNode());
                            date = await showDatePicker(
                              context: context, 
                              initialDate: DateTime.now(), 
                              firstDate: DateTime(1900, 1, 1, 1, 1), 
                              lastDate: DateTime(2200),

                            );
                            DateFormat formatter = DateFormat("dd.MM.yyy");
                            endDateCtrl.text = formatter.format(date!);
                          },
                          onChanged: (val) {
                            endDate = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: null
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: startTimeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Start Time',
                            //filled: true,
                            icon: Icon(Icons.timer),
                            labelStyle:
                                TextStyle(decorationStyle: TextDecorationStyle.solid),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Time";
                            }
                            return null;
                          },
                          onTap: () async {
                            TimeOfDay? time = TimeOfDay.now();
                            FocusScope.of(context).requestFocus(FocusNode());
                            time = await showTimePicker(
                              context: context, 
                              initialTime: const TimeOfDay(hour: 0, minute: 0),
                            );
                            startTimeCtrl.text = time!.format(context);
                          },
                          onChanged: (val) {
                            startTime = val;
                          },
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: endTimeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'End Time (Opt)',
                            //filled: true,
                            icon: Icon(Icons.timer),
                            labelStyle:
                                TextStyle(decorationStyle: TextDecorationStyle.solid),
                          ),
                          validator: null,
                          onTap: () async {
                            TimeOfDay? time = TimeOfDay.now();
                            FocusScope.of(context).requestFocus(FocusNode());
                            time = await showTimePicker(
                              context: context, 
                              initialTime: const TimeOfDay(hour: 0, minute: 0),
                            );
                            endTimeCtrl.text = time!.format(context);
                          },
                          onChanged: (val) {
                            endTime = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), 
                        labelText: "Max. Number Participants"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Maximum Number of Participants!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      maxNumParticipants = int.parse(val);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),

                  const Text("Participants:"),

                  ListTile(
                    title: const Text("Generate Participants (only Numbers)"),
                    leading: Radio(
                      value: 1, 
                      groupValue: _value, 
                      onChanged: (int? value) {
                        if (value == 1) {
                          setState(() {
                            _value = value!;
                            _buttonLabel = "Create";
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Create Participants manually in next step"),
                    leading: Radio(
                      value: 2, 
                      groupValue: _value, 
                      onChanged: (int? value) {
                        if (value == 2) {
                          setState(() {
                            _value = value!;
                            _buttonLabel = "Next Step";
                          });
                        }
                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: null
                  ),
                  ElevatedButton(
                    onPressed: (){
                      if (formkey.currentState!.validate()) {
                        if (_value == 1) {
                          Event event = Event(uid, eventName!, startDateCtrl.text, endDateCtrl.text, maxNumParticipants!, true);
                          event.addParticipants(generateParticipantList(maxNumParticipants!));
                          db.collection("events").add(event.toJSON());
                          Navigator.pop(context);
                          User? user = FirebaseAuth.instance.currentUser;
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: user!.uid)));
                        } else if (_value == 2) {
                          Event event = Event(uid, eventName!, startDateCtrl.text, endDateCtrl.text, maxNumParticipants!, false);
                          User? user = FirebaseAuth.instance.currentUser;
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ParticipantCreationPage()));
                        }
                      }
                    }, 
                    child: Text(_buttonLabel),
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