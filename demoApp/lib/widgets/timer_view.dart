import 'dart:developer';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/participant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();

  List<String> events = [];
  late String _currentEvent;
  Map<String, dynamic> _selectedEvent = {};

  static const countdownDuration = Duration(minutes: 10);
  Duration duration = const Duration();
  Timer? timer;
  bool countDown = false;
  bool addDuration = true;

  List markedParticipants = [];

  List timeBuffer = [];

  bool equalTimes(String a, String b) {
    Duration aT = Duration(
      hours: int.parse(a.split(":")[0]),
      minutes: int.parse(a.split(":")[1]),
      seconds: int.parse(a.split(":")[2]),
    );
    Duration bT = Duration(
      hours: int.parse(b.split(":")[0]),
      minutes: int.parse(b.split(":")[1]),
      seconds: int.parse(b.split(":")[2]),
    );
    if (aT.inSeconds == bT.inSeconds) {
      return true;
    } else {
      return false;
    }
  }


  setRanking() {
    // TODO: get ranking by age-classes?

    log("Setting the places of the participants");
    List<dynamic> result = _selectedEvent["result"];
    List<dynamic> finished = result.where(
      (element) => element["state"] == 4
    ).toList();
    List<dynamic> dnfs = result.where(
      (element) => element["place"] == -1
    ).toList();

    if (_selectedEvent["generatedParticipants"]) {
      sortResults(finished);
      _selectedEvent['result'] = finished + dnfs;
    } else {
      _selectedEvent['result'] = dnfs;
      List<dynamic> male = finished.where(
        (element) {
          log(element.toString());
          if (element['sex'] == "male") {
            return true;
          }
          return false;
        }
      ).toList();
      List<dynamic> female = finished.where(
        (element) {
          log(element.toString());
          if (element['sex'] == "female") {
            return true;
          }
          return false;
        }
      ).toList();
      List<dynamic> diverse = finished.where(
        (element) {
          log(element.toString());
          if (element['sex'] == "diverse") {
            return true;
          }
          return false;
        }
      ).toList();

      log("\n\nGender Lists\n\n");
      log(male.toString());
      log(female.toString());
      log(diverse.toString());

      if (male.isNotEmpty) sortResults(male);
      if (female.isNotEmpty) sortResults(female);
      if (diverse.isNotEmpty) sortResults(diverse);

      log("\n\nSorted Gender Lists\n\n");
      log(male.toString());
      log(female.toString());
      log(diverse.toString());

      _selectedEvent["maleResults"] = male;
      _selectedEvent["femaleResults"] = female;
      _selectedEvent["diverseResults"] = diverse;
    }

    fb.updateDocumentById("events_new", _selectedEvent['uid'], _selectedEvent);
  }


  sortResults(List<dynamic> finished) {
    finished.sort((a, b) {
      log(a.toString());
      Duration aT = Duration(
        hours: int.parse(a['time'].split(":")[0]),
        minutes: int.parse(a['time'].split(":")[1]),
        seconds: int.parse(a['time'].split(":")[2]),
      );
      Duration bT = Duration(
        hours: int.parse(b['time'].split(":")[0]),
        minutes: int.parse(b['time'].split(":")[1]),
        seconds: int.parse(b['time'].split(":")[2]),
      );
      return aT.compareTo(bT);
    });

    int counter = 1;
    String lastTime = finished[0]['time'];

    for (int i = 0; i < finished.length; i++) {
      if (equalTimes(finished[i]['time'], lastTime) && i > 0) {
        finished[i]['place'] = finished[i-1]['place'];
      } else {
        finished[i]['place'] = counter;
      }
      lastTime = finished[i]['time'];
      counter++;
    }
  }

  setAllParticipantsToRunning() {
    if (_currentEvent != "None") {
      log(_selectedEvent["participants"].toString());
      List results = [];
      for (Map<String, dynamic> p in _selectedEvent["participants"]) {
        if (p["state"] != EventState.dns.index) {
          p['state'] = EventState.running.index;
        }
        results.add(p);
      }
      log(results.toString());
      _selectedEvent["participants"] = results;
      fb.updateDocumentById("participants_new", _selectedEvent['eid'], _selectedEvent);
      log(_selectedEvent["participants"].toString());
    }
  }

  setAllParticipantsToDNF() async {
    if (_currentEvent != "None") {
      List<dynamic> results = _selectedEvent["result"];
      List parts = [];
      for (Map<String, dynamic> p in _selectedEvent["participants"]) {
        bool found = false;
        for (Map<String, dynamic> r in results) {
          if (r["number"] == p["number"]) {
            found = true;
            p["state"] = EventState.finished.index;
            parts.add(p);
            break;
          }
        }
        if (!found) {
          if (p["state"] != EventState.dns.index) p["state"] = EventState.dnf.index;
          parts.add(p);
          if (_selectedEvent["generatedParticipants"]) {
            results.add(
              {
                'number': p['number'],
                'place': -1,
                'state': EventState.dnf.index,
                'time': "",
              }
            );
          } else {
            results.add(
              {
                'number': p['number'],
                'place': -1,
                'state': EventState.dnf.index,
                'time': "",
                'uid': p['uid'],
                'gender': p['sex'],
              }
            );
          }
        }
      }
      _selectedEvent["result"] = results;
      // _selectedEvent["maleResults"] = male;
      // _selectedEvent["femaleResults"] = female;
      // _selectedEvent["diverseResults"] = diverse;
      _selectedEvent["participants"] = parts;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentEvent = "None";
    _selectedEvent = {};
  }

  @override
  void dispose() {
    if (timer != null) {
      if (timer!.isActive) {
        timer!.cancel();
      }
    }

    super.dispose();
  }

  void addTime(){
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0){
        timer?.cancel();
      } else{
        DateTime now = DateTime.now();
        DateTime end = DateTime(
          int.parse(_selectedEvent["enddate"]['date'].split(".")[2]),
          int.parse(_selectedEvent["enddate"]['date'].split(".")[1]),
          int.parse(_selectedEvent["enddate"]['date'].split(".")[0]),
          int.parse(_selectedEvent["enddate"]['time'].split(":")[0]),
          int.parse(_selectedEvent["enddate"]['time'].split(":")[1]),
        );
        log(end.difference(now).isNegative.toString());
        if (end.difference(now) <= const Duration(seconds: 0)) {
          timer?.cancel();
          String twoDigits(int n) => n.toString().padLeft(2,'0');
          String hours = twoDigits(duration.inHours);
          String minutes =twoDigits(duration.inMinutes.remainder(60));
          String seconds =twoDigits(duration.inSeconds.remainder(60));
          _selectedEvent["finalTime"] = hours + ":" + minutes + ":" + seconds;
          _selectedEvent["finished"] = true;
          setAllParticipantsToDNF();
          setRanking();
          fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
          log("Event finished");
        } else {
          if (addDuration) {
            duration = Duration(seconds: seconds);
          }
        }
      }
    });
  }

  void reset(){
    log("Resetting the Timer");
    if (countDown){
      setState(() =>
        duration = countdownDuration);
    } else{
      setState(() =>
        duration = const Duration());
    }
  }

  void stopTimer({bool resets = false}){
    log("Stopping the Timer");
    if (resets){
      reset();
    }
    setState(() {
      if (timer != null) {
        addDuration = false;
        timer!.cancel();
      }
    });
  }

  void startTimer(){
    log("Starting the Timer");
    timer = Timer.periodic(const Duration(seconds: 1),(_) => addTime());
  }

  Widget buildTime(){
    String twoDigits(int n) => n.toString().padLeft(2,'0');

    if (_selectedEvent["finished"]) {
      String finalTime = _selectedEvent["finalTime"];
      String hours = finalTime.split(":")[0];
      String minutes = finalTime.split(":")[1];
      String seconds = finalTime.split(":")[2];
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeCard(time: hours, header:'HOURS'),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015,),
          buildTimeCard(time: minutes, header:'MINUTES'),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015,),
          buildTimeCard(time: seconds, header:'SECONDS'),
        ]
      );
    } else {
      final hours = twoDigits(duration.inHours);
      final minutes =twoDigits(duration.inMinutes.remainder(60));
      final seconds =twoDigits(duration.inSeconds.remainder(60));
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeCard(time: hours, header:'HOURS'),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015,),
          buildTimeCard(time: minutes, header:'MINUTES'),
          SizedBox(width: MediaQuery.of(context).size.width * 0.015,),
          buildTimeCard(time: seconds, header:'SECONDS'),
        ]
      );
    }
  }

  Widget buildTimeCard({required String time, required String header}) =>
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(232, 255, 24, 100),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            time, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 16, 70, 65),
              fontSize: 50
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          header,
          style: const TextStyle(
            color: Color.fromARGB(255, 231, 250, 60)
          )
        ),
      ],
    );

  Widget getStopWatch() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTime(),
          // const SizedBox(height: 80,),
          // buildButtons()
        ],
      ),
    );
  }

  getTakeTimeDialog(String? time, bool skip) {
    
    if (time == null) {
      String t = duration.toString().split(".")[0];
      log(t);
      time = t.split(":")[0] + ":" + t.split(":")[1] + ":" + t.split(":")[2];
    }
    List<dynamic> participants = (_selectedEvent['participants'] as List<dynamic>).where(
      (element) => element['state'] == EventState.running.index).toList();
    return showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.only(left: 5.0, top: 45.0),
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
            height: skip ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.9,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter markedState) {
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        (time!=null) ? 
                          "Set time of " + time + " to which Participant?" : 
                          "Time was taken!",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 231, 250, 60),
                          fontWeight: FontWeight.bold,
                          fontSize: 22
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    skip ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            markedParticipants = [];
                            String take = duration.toString().split(".")[0];
                            log(take);
                            List buffer = _selectedEvent['timeBuffer'];
                            buffer.add(take);
                            fb.updateDocumentById("events_new", _selectedEvent['eid'], _selectedEvent);
                          });
                          Navigator.of(context).pop();
                        }, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 255, 100))
                        ),
                        child: const Text(
                          "Skip and add to Buffer!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromARGB(156, 9, 31, 29)
                          ),
                        )
                      ),
                    ) : const SizedBox(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: const Text(
                        "Choose participants to apply to given time!",
                        style: TextStyle(
                          color: Color.fromARGB(255, 231, 250, 60),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    _selectedEvent['generatedParticipants'] ? 
                      getGeneratedAddParticipants(participants, markedState) :
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: ListView.builder(
                          itemCount: participants.length,
                          itemBuilder: (context, index) {
                            String uid = participants[index]["uid"];
                            return FutureBuilder(
                              future: db.collection("participants_new").doc(uid).get(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  return Container( 
                                    margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                                    height: MediaQuery.of(context).size.height * 0.05, 
                                    child: TextButton(
                                      onPressed: () {
                                        if (markedParticipants.contains(participants[index]['number'])) {
                                          markedState(() {
                                            markedParticipants.remove(participants[index]['number']);
                                          });
                                        } else {
                                          markedState(() {
                                            markedParticipants.add(participants[index]['number']);
                                          });
                                        }
                                      },
                                      child: Text(
                                        snapshot.data!["firstname"] + " " + snapshot.data!["secondname"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: markedParticipants.contains(participants[index]['number']) ? 
                                              const Color.fromARGB(255, 49, 98, 94) :
                                              const Color.fromARGB(255, 212, 233, 20),
                                        ),
                                      ),
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
                                            markedParticipants.contains(participants[index]['number']) ? 
                                              const Color.fromARGB(255, 212, 233, 20) : 
                                              const Color.fromRGBO(49, 98, 94, 50),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Text("Something went wrong");
                                }
                              },
                            );
                          }
                        ),
                      ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: TextButton(
                        onPressed: markedParticipants.isEmpty ? null : () {
                          log("Apply Time to selected Participants");
                          log(markedParticipants.toString());
                          setTimeToParticipants(time!);
                          fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
                          markedParticipants = [];
                          timeBuffer.removeWhere((element) => element == time);
                          _selectedEvent['timeBuffer'] = timeBuffer;
                          fb.updateDocumentById(
                            "events_new", 
                            _selectedEvent["eid"], 
                            _selectedEvent
                          );
                          Navigator.of(context).pop();
                        }, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            markedParticipants.isEmpty ? const Color.fromARGB(255, 151, 161, 59) : const Color.fromARGB(255, 239, 255, 100)
                          )
                        ),
                        child: const Text(
                          "Apply time to selected Participants!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromARGB(156, 9, 31, 29)
                          ),
                        )
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        }, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 239, 255, 100)
                          )
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
                );
              }
            ),
          ),
        );
      }
    );
  }

  setTimeToParticipants(String time) async {
    if (time.split(":")[0] == "0") {
      time = "0" + time;
    }
    bool isGenerated = _selectedEvent["generatedParticipants"];
    List add = [];
    for (int number in markedParticipants) {
      Map<String, dynamic> part = (_selectedEvent['participants'] as List).where(
        (element) => element['number'] == number).toList().first;
      
      if (isGenerated) {
        add.add(
          {
            'number': part['number'],
            'time': time,
            'state': EventState.finished.index,
            'place': -1,
          }
        );

      } else {
        add.add(
          {
            'number': part['number'],
            'time': time,
            'state': EventState.finished.index,
            'place': -1,
            'uid': part['uid'],
            'sex': await fb.readDocumentById("participants_new", part["uid"]).then((value) => value!["sex"]),
            'age': await fb.readDocumentById("participants_new", part["uid"]).then((value) => getAge(value!["birthdate"])),
          }
        );
      }

      part['state'] = EventState.finished.index;
      List selParts = (_selectedEvent['participants'] as List);
      for (int i = 0; i < selParts.length; i++) {
        if (selParts[i]['number'] == part['number']) {
          selParts[i] = part;
          break;
        }
      }
      _selectedEvent['participants'] = selParts;
    }
    (_selectedEvent['result'] as List).addAll(add);
    fb.updateDocumentById("events_new", _selectedEvent['eid'], _selectedEvent);
  }

  int getAge(birthdate){
    var now = DateTime.now();
    var birth = DateTime(
      int.parse(birthdate.split(".")[2]),
      int.parse(birthdate.split(".")[1]),
      int.parse(birthdate.split(".")[0]),
    );

    if ((now.month < birth.month) || (now.month == birth.month && now.day < birth.day)) {
      return now.year-birth.year-1;
    } else {
      return now.year-birth.year;
    }
  }

  getGeneratedAddParticipants(List<dynamic> participants, markedState) {
    List<Widget> children = [];
    for(var p in participants) {
      children.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.width * 0.15,
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              log("Pressed Participant!");
              if (markedParticipants.contains(p['number'])) {
                markedState(() {
                  markedParticipants.remove(p['number']);
                });
              } else {
                markedState(() {
                  markedParticipants.add(p['number']);
                });
              }
            }, 
            child: Center(
              child:Text(
                p["number"].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: p["number"] < 10 ? 14 : (p["number"] < 100 ? 13 : 9),
                  color: markedParticipants.contains(p['number']) ? 
                    const Color.fromARGB(255, 49, 98, 94) :
                    const Color.fromARGB(255, 212, 233, 20),
                ),
              ),
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<CircleBorder>(
                const CircleBorder(
                  side: BorderSide(
                    color: Color.fromARGB(255, 212, 233, 20),
                    width: 2
                  ),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(
                markedParticipants.contains(p['number']) ? 
                  const Color.fromARGB(255, 212, 233, 20) : 
                  const Color.fromRGBO(49, 98, 94, 50),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.width * 0.55,
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget getButtons() {
    if (_currentEvent != "None") {
      if (_selectedEvent['started']) {
        Map<String, dynamic> started = _selectedEvent['startedDate'];
        duration = DateTime.now().difference(
          DateTime(
            int.parse(started['date'].split(".")[2]),
            int.parse(started['date'].split(".")[1]),
            int.parse(started['date'].split(".")[0]),
            int.parse(started['time'].split(":")[0]),
            int.parse(started['time'].split(":")[1]),
            int.parse(started['time'].split(":")[2]),
          )
        );

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.59,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(232, 255, 24, 100),
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    const Text(
                      "TIMER",
                      style: TextStyle(
                        color: Color.fromARGB(255, 231, 250, 60),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    getStopWatch(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Finished: ",
                          style: TextStyle(
                            color: Color.fromARGB(255, 231, 250, 60),
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _selectedEvent['result'].length.toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 231, 250, 60),
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "/" + 
                          _selectedEvent['maxNumParticipants'].toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 231, 250, 60),
                            fontSize: 20,
                          ),
                        ),
                        const Icon(
                          Icons.flag,
                          color: Color.fromARGB(255, 231, 250, 60),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.28,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(232, 255, 24, 100),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: getTimeList()
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.height * 0.14,
                            height: MediaQuery.of(context).size.height * 0.14,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: _selectedEvent['finished'] ? null : () {
                                getTakeTimeDialog(null, true);
                              }, 
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.alarm_add_sharp,
                                    color: const Color.fromARGB(156, 9, 31, 29),
                                    size: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                  const Text(
                                    "Take Time",
                                    style: TextStyle(
                                      color: Color.fromARGB(156, 9, 31, 29),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(const CircleBorder()),
                                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                                backgroundColor: MaterialStateProperty.all(
                                  _selectedEvent["finished"] ?  const Color.fromARGB(255, 137, 148, 38) : const Color.fromARGB(255, 231, 250, 60)
                                ),
                                overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.pressed)) return const Color.fromARGB(255, 182, 197, 47);
                                  return null;
                                }),
                                side: MaterialStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: Color.fromARGB(255, 39, 129, 122),
                                    width: 3,
                                  )
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(MediaQuery.of(context).size.height * 0.11, MediaQuery.of(context).size.height * 0.2),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.height * 0.11,
                            height: MediaQuery.of(context).size.height * 0.11,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: _selectedEvent['finished'] ? null : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color.fromARGB(255, 182, 197, 47),
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                      "Hold Button to end the Event. This can not be undone!",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 9, 31, 29),
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  )
                                );
                              }, 
                              onLongPress: _selectedEvent['finished'] ? null : () {
                                stopTimer();
                                String twoDigits(int n) => n.toString().padLeft(2,'0');
                                String hours = twoDigits(duration.inHours);
                                String minutes =twoDigits(duration.inMinutes.remainder(60));
                                String seconds =twoDigits(duration.inSeconds.remainder(60));
                                _selectedEvent["finalTime"] = hours + ":" + minutes + ":" + seconds;
                                _selectedEvent['finished'] = true;
                                timeBuffer = [];
                                _selectedEvent["timeBuffer"] = [];
                                setAllParticipantsToDNF();
                                setRanking();
                                fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
                                // TODO: show that Event has ended
                                Navigator.of(context).popUntil(ModalRoute.withName("/"));
                              },
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.celebration,
                                    color: Color.fromARGB(156, 9, 31, 29),
                                    size: 20,
                                  ),
                                  Text(
                                    "End",
                                    style: TextStyle(
                                      color: Color.fromARGB(156, 9, 31, 29),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(const CircleBorder()),
                                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                                backgroundColor: MaterialStateProperty.all(
                                  _selectedEvent["finished"] ?  const Color.fromARGB(255, 137, 148, 38) : const Color.fromARGB(255, 231, 250, 60)
                                ),
                                overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.pressed)) return const Color.fromARGB(255, 182, 197, 47);
                                  return null; 
                                }),
                                side: MaterialStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: Color.fromARGB(255, 39, 129, 122),
                                    width: 3,
                                  )
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(MediaQuery.of(context).size.height * 0.11, MediaQuery.of(context).size.height * 0.11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Image.asset(
              "lib/assets/Standing_Runner.png",
              height: MediaQuery.of(context).size.height*0.3
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: const Text(
                "Your Event hasn't started yet!",
                style: TextStyle(
                  color: Color.fromARGB(255, 231, 250, 60),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedEvent['started'] = true;
                    DateTime now = DateTime.now();
                    _selectedEvent["startedDate"] = {
                      'date': now.day.toString() + "." + now.month.toString() + "." + now.year.toString(),
                      'time': now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString(),
                    };
                    setAllParticipantsToRunning();
                    fb.updateDocumentById(
                      "events_new", 
                      _selectedEvent["eid"], 
                      _selectedEvent
                    );
                    startTimer();
                  });
                },
                child: const Text(
                  "Let's Go! Start Event!",
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
              )
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "By hitting the button, the Event will start and the time is running!",
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromARGB(255, 231, 250, 60)
                ),
                textAlign: TextAlign.center,
              )
            ),
          ],
        );
      }
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.59,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Image.asset(
              "lib/assets/Standing_Runner.png",
              height: MediaQuery.of(context).size.height*0.4
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              child: const Text(
                "Please Select an Event to get started!",
                style: TextStyle(
                  color: Color.fromARGB(255, 231, 250, 60),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget getTimeList() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.26,
      alignment: Alignment.centerRight,
      child:  Center(
        child: ListView.builder(
          itemCount: timeBuffer.length,
          itemBuilder: (context, index) {
            final item = timeBuffer[index];
            return Dismissible(
              key: Key(item), 
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                setState(() {
                  timeBuffer.removeAt(index);
                  log(timeBuffer.toString());
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color.fromARGB(255, 182, 197, 47),
                    duration: Duration(seconds: 1),
                    content: Text(
                      "Time was removed!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 31, 29),
                        fontWeight: FontWeight.bold
                      ),
                    )
                  )
                );
              },
              background: Container(
                height: MediaQuery.of(context).size.height * 0.02,
                // color: Colors.red,
                alignment: Alignment.center,
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete_outline,
                      color: Color.fromARGB(255, 212, 233, 20),
                    ),
                    Text(
                      "Delete",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 239, 255, 100),
                      ),
                    )
                  ],
                )
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.33,
                height: MediaQuery.of(context).size.height * 0.04,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0, top: 5.0),
                child: TextButton(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 239, 255, 100),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    log(item);
                    getTakeTimeDialog(item, false);
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
                )
              ),
            );
          }
        ),
      ),
    );
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
            height: MediaQuery.of(context).size.height * 0.04,
            child: const Text(
              "Choose Event!",
              style: TextStyle(
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
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(232, 255, 24, 100),
              width: 2,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: db.collection("events_new").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Loading ...");
              } else {
                List<DropdownMenuItem<String>> events = [];
                for (DocumentSnapshot doc in snapshot.data!.docs) {
                  if (doc['uid'] == user.uid) {
                    events.add(
                      DropdownMenuItem(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            doc['name'],
                            style: TextStyle(
                              color: const Color.fromARGB(255, 231, 250, 60),
                              fontWeight: doc['name'] == _currentEvent ? FontWeight.bold : FontWeight.normal
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (timeBuffer.isNotEmpty) {
                              _selectedEvent["timeBuffer"] = timeBuffer;
                              fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
                            }
                            _selectedEvent = (doc.data() as Map<String, dynamic>);
                          });
                        },
                        value: doc['name'],
                      )
                    );
                  }
                }

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.08,
                      ),
                      DropdownButton(
                        items: [
                          DropdownMenuItem<String>(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Text(
                                "None",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 231, 250, 60),
                                  fontWeight: "None" == _currentEvent ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                            ),
                            value: "None",
                            onTap: () => setState(() {
                              if (timeBuffer.isNotEmpty) {
                                _selectedEvent["timeBuffer"] = timeBuffer;
                                fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
                              }
                              _selectedEvent = {};
                              _currentEvent = "None";
                            }),
                          )
                        ] + events, 
                        value: _currentEvent,
                        onChanged: (_val) {
                          setState(() {
                            stopTimer();
                            _currentEvent = _val as String;
                            if (_val != "None") {
                              // setRanking();
                              if (!_selectedEvent["finished"] && _selectedEvent["started"]) {
                                startTimer();
                              } else if (_selectedEvent["finished"] && _selectedEvent["started"]) {
                                String time = _selectedEvent["finalTime"];
                                duration = Duration(
                                  hours: int.parse(time.split(":")[0]),
                                  minutes: int.parse(time.split(":")[1]),
                                  seconds: int.parse(time.split(":")[2]),
                                );
                              }
                              timeBuffer = _selectedEvent["timeBuffer"];
                            } else {
                              timeBuffer = [];
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Color.fromARGB(255, 231, 250, 60),
                          size: 40,
                        ),
                        dropdownColor: const Color.fromARGB(255, 55, 109, 104),
                        borderRadius: BorderRadius.circular(15.0),
                        underline: const SizedBox(),
                      ),
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.08,
                      // ),
                    ],
                  ),
                );
              }
            }
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        getButtons()
      ],
    );
  }
}