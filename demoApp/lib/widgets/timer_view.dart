import 'dart:async';

import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/controllers/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';


class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerViewState();
}

// TODO: wenn wechsel auf andere Seite, dann wird weiterhin 
// addTime ausgeführt bzw. setState, somit viel error output und absturz

class _TimerViewState extends State<TimerView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();

  List<String> events = [];
  var _currentEvent;
  Map<String, dynamic> _selectedEvent = {};

  static const countdownDuration = Duration(minutes: 10);
  Duration duration = const Duration();
  Timer? timer;

  bool countDown = false;

  bool addDuration = true;

  // TextEditingController time = TextEditingController();

  @override
  void initState() {
    log("TEst");
    super.initState();
    _currentEvent = "None";
    _selectedEvent = {};
  }

  @override
  void dispose() {
    log("shfgshf");
    stopTimer();
    super.dispose();
  }

  void addTime(){
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0){
        timer?.cancel();
      } else{
        log(addDuration.toString());
        if (addDuration) {
          log(seconds.toString());
          duration = Duration(seconds: seconds);
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
        log(timer!.isActive.toString());
        addDuration = false;
        timer!.cancel();
        _selectedEvent['finished'] = true;
        fb.updateDocumentById("events_new", _selectedEvent['eid'], _selectedEvent);
        // timer = Timer.periodic(const Duration(seconds: 0),(_) => addTime());
        log(timer!.isActive.toString());
      }
    });
  }

  void startTimer(){
    log("Starting the TImer");
    if (_selectedEvent["finished"]) {
      timer = Timer.periodic(const Duration(seconds: 1),(_) => addTime());
    } else {
      String time = _selectedEvent["finalTime"];
      timer = Timer.periodic(Duration(
        hours: int.parse(time.split(":")[0]),
        minutes: int.parse(time.split(":")[1]),
        seconds: int.parse(time.split(":")[2]),
      ),(_) => addTime());
    }
  }

  Widget buildTime(){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
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

  Widget getButtons() {
    // TODO: put in the needed widgets for the buttons
    if (_selectedEvent.isNotEmpty) {
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
        
        return Column(
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
                        // TODO: from finished List
                        _selectedEvent['participants'].length.toString(),
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
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.height * 0.2,
                    height: MediaQuery.of(context).size.height * 0.2,
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO
                        // startTimer();
                      }, 
                      // alarm add sharp
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.alarm_add_sharp,
                            color: Color.fromARGB(156, 9, 31, 29),
                            size: 30,
                          ),
                          Text(
                            "Take Time",
                            style: TextStyle(
                              color: Color.fromARGB(156, 9, 31, 29),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 231, 250, 60)), // <-- Button color
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.pressed)) return Color.fromARGB(255, 182, 197, 47); // <-- Splash color
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.height * 0.11,
                        height: MediaQuery.of(context).size.height * 0.11,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO
                          }, 
                          child: Column(
                            children: const [
                              Icon(
                                Icons.assignment_rounded,
                                color: Color.fromARGB(156, 9, 31, 29),
                                size: 20,
                              ),
                              Text(
                                "List",
                                style: TextStyle(
                                  color: Color.fromARGB(156, 9, 31, 29),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 231, 250, 60)),
                            overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.pressed)) return const Color.fromARGB(255, 182, 197, 47);
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.height * 0.11,
                        height: MediaQuery.of(context).size.height * 0.11,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: _selectedEvent['finished'] ? null : () {
                            // TODO
                            stopTimer();
                            String twoDigits(int n) => n.toString().padLeft(2,'0');
                            String hours = twoDigits(duration.inHours);
                            String minutes =twoDigits(duration.inMinutes.remainder(60));
                            String seconds =twoDigits(duration.inSeconds.remainder(60));
                            // TODO: format to time and write to firebase
                            _selectedEvent["finalTime"] = hours + ":" + minutes + ":" + seconds;
                            fb.updateDocumentById("events_new", _selectedEvent["eid"], _selectedEvent);
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
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // child: Text("End Event"),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                              _selectedEvent["finished"] ?  const Color.fromARGB(255, 137, 148, 38) : const Color.fromARGB(255, 231, 250, 60)
                            ),
                            overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.pressed)) return Color.fromARGB(255, 182, 197, 47); // <-- Splash color
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
                ],
              ),
            ),
          ],
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
                  // TODO start the event and switch layout
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
      return Column(
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
          const Text(
            "Please Select an Event to get started!",
            style: TextStyle(
              color: Color.fromARGB(255, 231, 250, 60),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        const Center(
          child: Text(
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
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
                            log(doc.data().toString());
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
                              _selectedEvent = {};
                            }),
                          )
                        ] + events, 
                        value: _currentEvent,
                        onChanged: (_val) {
                          setState(() {
                            _currentEvent = _val as String;
                            if (!_selectedEvent["finished"]) {
                              startTimer();
                            } else {
                              String time = _selectedEvent["finalTime"];
                              duration = Duration(
                                hours: int.parse(time.split(":")[0]),
                                minutes: int.parse(time.split(":")[1]),
                                seconds: int.parse(time.split(":")[2]),
                              );
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
        // SizedBox(
        //   height: MediaQuery.of(context).size.height * 0.03,
        // ),
        // Container(
        //   child: Text("TIME & finished Participants")
        // ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        getButtons()
      ],
    );
  }
}