// ignore_for_file: file_names

import 'package:demo_app/models/event.dart';
import 'package:demo_app/controllers/firebase.dart';
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

  TextEditingController eventname = TextEditingController();

  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  
  TextEditingController endDateCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();
  
  TextEditingController numParticipantsCtrl = TextEditingController();

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

    try{
      Event event = Event(
        "tmp",
        user.uid,
        eventname.text,
        EventDate.fromEventDate(
          startDateCtrl.text, 
          startTimeCtrl.text, 
        ),
        EventDate.fromEventDate(
          endDateCtrl.text, 
          endTimeCtrl.text,
        ),
        int.parse(numParticipantsCtrl.text),
        [],
        !_onlyStartnumbers
      );

      // print(event);

      log(event.toString());

      DocumentReference? res = await fb.addDocument("events_new", event.toJSON());
      fb.updateDocument("events_new", res!, {'eid': res.id});
      Navigator.of(context).pop();
    } catch(e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    formkey = GlobalKey<FormState>();
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
                              controller: eventname,
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
                              // TODO add validatort
                              validator: null,
                              // TODO check input
                              onChanged: null,
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
                                getDatePicker("Start", startDateCtrl, startTimeCtrl),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.1,
                                ),
                                getDatePicker("End", endDateCtrl, endTimeCtrl),
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
                              // TODO: add validation
                              validator: null,
                              // TODO: check input
                              onChanged: null,
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
                  onPressed: () {
                    createEvent();
                  }, 
                  child: const Text(
                    "Create",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
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
    TextEditingController timeCtrl
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
                DateFormat formatter = DateFormat("dd.MM.yyy");
                if (date != null) {
                  dateCtrl.text = formatter.format(date);
                }
              },
              // TODO: add validation
              validator: null,
              // TODO: check input
              onChanged: null,
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
              // TODO: add validation
              validator: null,
              // TODO: check input
              onChanged: null,
            ),
          ),
        ],
      );
  }
}

