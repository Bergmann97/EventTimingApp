// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/participant.dart';
import 'package:demo_app/screens/viewEventScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

// ignore: must_be_immutable
class EditEventPage extends StatefulWidget {
  Event event;
  EditEventPage({Key? key, required this.event}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _EditEventPageState createState() => _EditEventPageState(event: event);
}

class _EditEventPageState extends State<EditEventPage> {

  User user = FirebaseAuth.instance.currentUser!;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  Event event;

  TextEditingController eventnameCtrl = TextEditingController();

  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  
  TextEditingController endDateCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();
  
  TextEditingController numParticipantsCtrl = TextEditingController();

  _EditEventPageState({required this.event});


  bool _buttondisabled = true;

  bool _manualParticipants = false;
  final db = FirebaseFirestore.instance;
  
  TextStyle formText = const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 231, 250, 60)
                );
  FirebaseHelper fb = FirebaseHelper();

  String formatTimeOfDay(TimeOfDay time) {
    int hour = time.hour;
    int min = time.minute;

    if (min < 10) {
      return hour.toString() + ":0" + min.toString();
    } else {
      return hour.toString() + ":" + min.toString();
    }
  }

  void updateEvent() async {
    // TODO: Wirft Fehler!
    bool _changed = false;

    // changing the standard values
    if (eventnameCtrl.text != event.getName() ||
        startDateCtrl.text != event.getStartdate().getDate() ||
        startTimeCtrl.text != event.getStartdate().getTime() ||
        endDateCtrl.text != event.getEnddate().getDate() ||
        endTimeCtrl.text != event.getEnddate().getTime()) {
      log("Standard Values changed");
      Map<String, dynamic> changes = {
        'name': eventnameCtrl.text,
        'startdate': {
          'date': startDateCtrl.text,
          'time': startTimeCtrl.text,
        },
        'enddate': {
          'date': endDateCtrl.text,
          'time': endTimeCtrl.text,
        }
      };

      try {
        await fb.updateDocumentById("events_new", event.getEid(), changes);
        _changed = true;
      } catch (e) {
        log(e.toString());
      }
    }

    List changesParticipants = [];

    // changing the participation type from generated to manual
    if (event.isGenerated() && _manualParticipants) { // change
      log("changed participant type to manual");
      try {
        // set flag to false and clear the participants
        await fb.updateDocumentById(
          "events_new", 
          event.getEid(), 
          {
            'participants': [], 
            'generatedParticipants': false
          }
        );
        changesParticipants = [];
        _changed = true;
      } catch (e) {
        log(e.toString());
      }
    } else {
      // changing the participation type from manual to generated
      if (!event.isGenerated() && !_manualParticipants) {
        log("changed participant type to generated");
        List newParticipants = [];
        // generate the new participant list
        for (int i = 0; i < int.parse(numParticipantsCtrl.text); i++) {
          newParticipants.add(
            {
              'number': i+1,
              'state': 0,
            }
          );
        }
        try {
          // set the flag, add the generated participants and set maxNumPart
          await fb.updateDocumentById(
            "events_new", 
            event.getEid(), 
            {
              'participants': newParticipants,
              'generatedParticipants': true,
              'maxNumParticipants': int.parse(numParticipantsCtrl.text),
            }
          );
          changesParticipants = newParticipants;
          _changed = true;
        } catch (e) {
          log(e.toString());
        }
      } else {  // not changing the participant type but the number of participants
        log("no type change");
        // adding more generated participants
        if (!_manualParticipants && event.getMaxNumParticipants() < int.parse(numParticipantsCtrl.text)) {
          log("increasing generated Participants");
          List newParticipants = event.getParticipants().map((e) => e.toJSON()).toList();
          for (int i = event.getMaxNumParticipants()-1; i < int.parse(numParticipantsCtrl.text); i++) {
            newParticipants.add(
              {
                'number': i+1,
                'state': 0,
              }
            );
          }
          try {
            // set the flag, add the generated participants and set maxNumPart
            await fb.updateDocumentById(
              "events_new", 
              event.getEid(), 
              {
                'participants': newParticipants,
                'generatedParticipants': true,
                'maxNumParticipants': int.parse(numParticipantsCtrl.text),
              }
            );
            changesParticipants = newParticipants;
            _changed = true;
          } catch (e) {
            log(e.toString());
          }
          log(newParticipants.toString());
        } else {
          // old participant list needs to be reduced
          if (event.getMaxNumParticipants() > int.parse(numParticipantsCtrl.text)) {
            log("decreasing any kind of Participants");
            List newParticipants = [];
            List old = event.getParticipants();
            int counter = 0;
            for (var item in old) {
              newParticipants.add(item);
              counter++;
              if (counter >= event.getMaxNumParticipants()) {break;}
            }

            // for (int i = 0; i < event.getMaxNumParticipants() || i >= old.length; i++) {
            //   newParticipants.add(
            //     old[i]
            //   );
            // }
            try {
              // set the flag, add the generated participants and set maxNumPart
              await fb.updateDocumentById(
                "events_new", 
                event.getEid(), 
                {
                  'participants': newParticipants,
                  'maxNumParticipants': int.parse(numParticipantsCtrl.text),
                }
              );
              changesParticipants = newParticipants;
              _changed = true;
            } catch (e) {
              log(e.toString());
            }
            log(newParticipants.toString());
          } else {
            // manual created participants and expansion of them
            if (_manualParticipants && event.getMaxNumParticipants() < int.parse(numParticipantsCtrl.text)) {
              log("increasing for manual Participants");
              try {
                // set the flag, add the generated participants and set maxNumPart
                await fb.updateDocumentById(
                  "events_new", 
                  event.getEid(), 
                  {
                    'maxNumParticipants': int.parse(numParticipantsCtrl.text),
                  }
                );
                _changed = true;
              } catch (e) {
                log(e.toString());
              }
            }
          }
        }

        if (event.getMaxNumParticipants() != int.parse(numParticipantsCtrl.text)) {
          log("number participants changed");
          Map<String, dynamic> changes = {
            "maxNumParticipants": int.parse(numParticipantsCtrl.text),
          };

          try {
            await fb.updateDocumentById(
              "events_new", 
              event.getEid(), 
              changes
            );
            _changed = true;
          } catch (e) {
            log(e.toString());
          }
        }
      }
    }

    Event nEvent = Event(
      event.getEid(),
      user.uid,
      eventnameCtrl.text,
      EventDate.fromEventDate(
        startDateCtrl.text,
        startTimeCtrl.text
      ),
      EventDate.fromEventDate(
        endDateCtrl.text,
        endTimeCtrl.text
      ),
      int.parse(numParticipantsCtrl.text),
      changesParticipants,
      _manualParticipants,
    );

    log(changesParticipants.toString());

    if (_changed) {
      log("Event needs to be updated");
      Navigator.pop(context, nEvent);
      // Navigator.pushReplacement(
      //   context, 
      //   MaterialPageRoute(
      //     builder: (context) => 
      //     ViewEventPage(event: nEvent,)
      //   )
      // );
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => ViewEventPage(event: nEvent, generated: !_manualParticipants,)
      //   )
      // );
    } else {
      log("Event did not change");
      setState(() {
        Navigator.of(context).pop();
      });
    }
    
        // if (e.getName() != event.getName() ||
    //     e.getStartdate().getDate() != event.getStartdate().getDate() ||
    //     e.getStartdate().getTime() != event.getStartdate().getTime() ||
    //     e.getEnddate().getDate() != event.getEnddate().getDate() ||
    //     e.getEnddate().getTime() != event.getEnddate().getTime() ||
    //     e.isGenerated() != event.isGenerated()) {

    //   List newParticipants = [];
    //   if (event.isGenerated() && !e.isGenerated()) {
    //     newParticipants = [];
    //   } else {
    //     if (!event.isGenerated() && e.isGenerated()) {
    //       if (e.getMaxNumParticipants() != event.getMaxNumParticipants()) {
    //         newParticipants = [];
    //         for (int i = event.getMaxNumParticipants(); i < int.parse(numParticipantsCtrl.text); i++) {
    //           newParticipants.add(
    //             GeneratedParticipant(
    //               i,
    //               EventState.values[0]
    //             )
    //           );
    //         }
    //       } else {
    //         newParticipants = [];
    //         for (int i = 0; i < event.getMaxNumParticipants(); i++) {
    //           newParticipants.add(
    //             GeneratedParticipant(
    //               i,
    //               EventState.values[0]
    //             )
    //           );
    //         }
    //       }
    //     } else {
    //       if (e.isGenerated() && e.getMaxNumParticipants() > event.getMaxNumParticipants()) {
    //         newParticipants = event.getParticipants();
    //         for (int i = event.getMaxNumParticipants(); i < int.parse(numParticipantsCtrl.text); i++) {
    //           newParticipants.add(
    //             GeneratedParticipant(
    //               i,
    //               EventState.values[0]
    //             )
    //           );
    //         }
    //       } else {
    //         if (e.isGenerated() && e.getMaxNumParticipants() < event.getMaxNumParticipants()) {
    //           for (int i = 0; i < e.getMaxNumParticipants(); i++) {
    //             newParticipants.add(event.getParticipants()[i]);
    //           }
    //         } else {
    //           newParticipants = event.getParticipants();
    //         }
    //       } 
    //     }
    //   }

    //   if (newParticipants != e.getParticipants()) {
    //     e.setParticipants(newParticipants);
    //     log("Change");
    //     // log(newParticipants.toString());
    //   }


    //   try{
    //     log(event.toString());

    //     Map<String, dynamic> changes = {
    //       'eid': event.getEid(),
    //       'uid': e.getUid(),
    //       'name': e.getName(),
    //       'startdate': e.getStartdate().toJSON(),
    //       'enddate': e.getEnddate().toJSON(),
    //       'maxNumParticipants': e.getMaxNumParticipants(),
    //       'participants': newParticipants.map((e) => e.toJSON()).toList(),
    //       'generatedParticipants': e.isGenerated(),
    //     };

    //     // log(newParticipants.map((e) => e.toJSON()).toList().toString());
    //     log(changes.toString());

    //     await fb.updateDocumentById("events_new", event.getEid(), changes);
    //     log("Event updated!");
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //         builder: (context) => 
    //           ViewEventPage(event: e,)
    //       )
    //     );
    //   } catch(e) {
    //     log(e.toString());
    //   }
    // } else {
    //   log("No Changes");
    // }
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
    eventnameCtrl.text = event.getName();
    startDateCtrl.text = event.getStartdate().getDate();
    startTimeCtrl.text = event.getStartdate().getTime();
    endDateCtrl.text = event.getEnddate().getDate();
    endTimeCtrl.text = event.getEnddate().getTime();
    numParticipantsCtrl.text = event.getMaxNumParticipants().toString();
    _manualParticipants = !event.isGenerated();
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, 
            color: Color.fromARGB(255, 239, 255, 100)
          ),
          onPressed: () {
            Navigator.pop(
              context, 
              event,
            );
          },
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
                                  value: _manualParticipants, 
                                  onChanged: (value) {
                                    setState(() {
                                      _manualParticipants = value;
                                      _buttondisabled = false;
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
                      updateEvent();
                    }
                  }, 
                  child: const Text(
                    "Confirm Changes",
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
                  setState(() {
                    _buttondisabled = false;
                  });
                } else {
                  setState(() {
                    _buttondisabled = true;
                  });
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
                  setState(() {
                    _buttondisabled = false;
                  });
                } else {
                  setState(() {
                    _buttondisabled = true;
                  });
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
        ],
      );
  }
}

