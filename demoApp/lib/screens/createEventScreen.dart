// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/participant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {

  User user = FirebaseAuth.instance.currentUser!;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController eventnameCtrl = TextEditingController();

  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  
  TextEditingController endDateCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();
  
  TextEditingController numParticipantsCtrl = TextEditingController();

  bool _buttondisabled = true;

  bool _onlyStartnumbers = false;
  final db = FirebaseFirestore.instance;
  
  TextStyle formText = const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 231, 250, 60)
                );


  String formatTimeOfDay(TimeOfDay time) {
    int hour = time.hour;
    int min = time.minute;

    if (min < 10) {
      return hour.toString() + ":0" + min.toString();
    } else {
      return hour.toString() + ":" + min.toString();
    }
  }

  
  void createEvent() async {
    FirebaseHelper fb = FirebaseHelper();

    List<dynamic> participants = [];
    if (!_onlyStartnumbers) {
      for (int i = 0; i < int.parse(numParticipantsCtrl.text); i++) {
        participants.add(
          GeneratedParticipant(
            i,
            EventState.values[0]
          ).toJSON()
        );
      }
    }

    try{
      Event event = Event(
        "tmp",
        user.uid,
        eventnameCtrl.text,
        EventDate.fromEventDate(
          startDateCtrl.text, 
          startTimeCtrl.text, 
        ),
        EventDate.fromEventDate(
          endDateCtrl.text, 
          endTimeCtrl.text,
        ),
        int.parse(numParticipantsCtrl.text),
        participants,
        !_onlyStartnumbers
      );

      log(event.toString());

      DocumentReference? res = await fb.addDocument("events_new", event.toJSON());
      fb.updateDocument("events_new", res!, {'eid': res.id});
      Navigator.of(context).pop();
      log("event Created!");
    } catch(e) {
      log(e.toString());
    }
  }

  int checkDates(String start, String end) {
    int startYear = int.parse(start.split(".")[2]);
    int startMonth = int.parse(start.split(".")[1]);
    int startDay = int.parse(start.split(".")[0]);

    int endYear = int.parse(end.split(".")[2]);
    int endMonth = int.parse(end.split(".")[1]);
    int endDay = int.parse(end.split(".")[0]);

    if (endYear < startYear) {
      return 2;
    } else {  // endYear >= startYear
      if (endMonth < startMonth) {
        return 2;
      } else {  // endMonth >= startMonth
        if (endDay < startDay) {
          return 2;
        } else {  // endDay >= startDay
          if (endDay == startDay) {
            return 1;
          } else {
            return 0;
          }
        }
      }
    }
  }

  bool checkTimes(String start, String end) {
    int startH = int.parse(start.split(":")[0]);
    int startM = int.parse(start.split(":")[1]);

    int endH = int.parse(end.split(":")[0]);
    int endM = int.parse(end.split(":")[1]);

    if (endH < startH) {
      return false;
    } else {
      if (endH == startH) {
        if (endM <= startM) {
          return false;
        } else {  // endM > endM
          return true;
        }
      } else {  // endH > startH
        return true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    formkey = GlobalKey<FormState>();
    _buttondisabled = true;
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
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView (
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
              const Text(
                "Create Event",
                style: TextStyle(
                  color: Color.fromARGB(255, 231, 250, 60),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(232, 255, 24, 100),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: const Color.fromRGBO(49, 98, 94, 100),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 7,
                      spreadRadius: 5,
                      offset: Offset(0, 5), 
                      color: Color.fromARGB(156, 9, 31, 29)
                    ),
                  ],
                ),
                child: Form(
                  key: formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text("Eventname", style: formText, textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextFormField(
                              controller: eventnameCtrl,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(212, 233, 20, 100),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(212, 233, 20, 100),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorMaxLines: 3,
                                labelText: "Eventname",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(212, 233, 20, 100),
                                ),
                              ),
                              validator: (_val) {
                                if (_val!.isEmpty) {
                                  return "Can't be empty";
                                } else {
                                  if (_val.length > 80) {
                                    return "The title can have at most 80 characters";
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getDatePicker("Start", startDateCtrl, startTimeCtrl, false),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.1,
                                ),
                                getDatePicker("End", endDateCtrl, endTimeCtrl, true),
                              ],
                            )
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text("Number of Participants", style: formText, textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: numParticipantsCtrl,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(212, 233, 20, 100),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(212, 233, 20, 100),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorMaxLines: 3,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (_val) {
                                if (_val!.isEmpty) {
                                  return "Can't be empty";
                                } else {
                                  if (!RegExp(r'^[0-9]+$').hasMatch(_val)) {
                                    return "This field cannot contain other than digits";
                                  } else {
                                    if (_val[0] == "0") {
                                      return "The number must start with digit > 0";
                                    } else {
                                      return null;
                                    }
                                  }
                                }
                              },
                              onChanged: (_val) {
                                if (eventnameCtrl.text.isNotEmpty &&
                                    startDateCtrl.text.isNotEmpty &&
                                    startTimeCtrl.text.isNotEmpty &&
                                    endDateCtrl.text.isNotEmpty &&
                                    endTimeCtrl.text.isNotEmpty &&
                                    numParticipantsCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _buttondisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _buttondisabled = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Switch(
                                  value: _onlyStartnumbers, 
                                  onChanged: (value) {
                                    setState(() {
                                      _onlyStartnumbers = value;
                                    });
                                  },
                                  activeColor: const Color.fromRGBO(212, 233, 20, 100),
                                ),
                                const Text(
                                  "manually add Participants",
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 231, 250, 60)
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: const Center(
                              child: Text(
                                "(otherwise you will only have a generated list of startnumbers)",
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Color.fromRGBO(212, 233, 20, 100)
                                ),
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton(
                  onPressed: _buttondisabled ? null : () {
                    if (formkey.currentState!.validate()) {
                      createEvent();
                    }
                  }, 
                  child: const Text(
                    "Create Event",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      // color: _buttondisabled ? const Color.fromRGBO(232, 255, 24, 100) : Colors.white
                      color: Color.fromARGB(156, 9, 31, 29)
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
                      _buttondisabled ? 
                        const Color.fromARGB(255, 145, 158, 31) : 
                        const Color.fromARGB(255, 231, 250, 60),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget getDatePicker(
    String title, 
    TextEditingController dateCtrl, 
    TextEditingController timeCtrl,
    bool endIndicator
  ) {
    return Column(
        children: [
          Text(title, style: formText,),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.07,
            child: TextFormField(
              readOnly: true,
              controller: dateCtrl,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(212, 233, 20, 100),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(212, 233, 20, 100),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                errorMaxLines: 3,
                labelText: "Date",
                labelStyle: TextStyle(
                  color: Color.fromRGBO(212, 233, 20, 100),
                ),
              ),
              onTap: () async {
                var date = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime(2300)
                );
                DateFormat formatter = DateFormat("dd.MM.yyyy");
                if (date != null) {
                  dateCtrl.text = formatter.format(date);
                }
              },
              validator: (_val) {
                if (_val!.isEmpty) {
                  return "Can't be empty";
                } else {
                  if (!RegExp(r'^\d{2}.\d{2}.\d{4}$').hasMatch(_val)) {
                    return "The date needs the form of: dd.mm.yyyy";
                  } else {
                    if (endIndicator) {
                      if (checkDates(startDateCtrl.text, _val) > 1) {
                        return "The Enddate needs to be later than the start date!";
                      } else {
                        return null;
                      }
                    } else {
                      return null;
                    }
                  }
                }
              },
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.07,
            child: TextFormField(
              readOnly: true,
              controller: timeCtrl,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(212, 233, 20, 100),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(212, 233, 20, 100),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                errorMaxLines: 3,
                labelText: "Time",
                labelStyle: TextStyle(
                  color: Color.fromRGBO(212, 233, 20, 100),
                ),
              ),
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context, 
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  timeCtrl.text = formatTimeOfDay(time);
                }
              },
              validator: (_val) {
                if (_val!.isEmpty) {
                  return "Can't be empty";
                } else {
                  if (RegExp(r'^\d{1}:\d{2}$').hasMatch(_val) || 
                      RegExp(r'^\d{2}:\d{2}$').hasMatch(_val)) {
                    if (endIndicator) {
                      if (checkDates(startDateCtrl.text, endDateCtrl.text) == 1 && 
                          !checkTimes(startTimeCtrl.text, _val)) {
                            return "End time needs to be after start time!";
                      } else {
                        return null;
                      }
                    } else {
                      return null;
                    }
                  } else {
                    return "The time needs the form of: hh:mm";
                  }
                }
              },
            ),
          ),
        ],
      );
  }
}

