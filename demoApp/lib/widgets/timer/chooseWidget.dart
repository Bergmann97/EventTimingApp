// ignore: file_names
import 'package:demo_app/controllers/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChooseEvent extends StatefulWidget {
  const ChooseEvent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChooseEventState();
}

class _ChooseEventState extends State<ChooseEvent> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  FirebaseHelper fb = FirebaseHelper();

  List<String> events = [];
  var _currentEvent;

  void initState() {
    super.initState();
    _currentEvent = "None";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
                      value: "None")
                    ] + events, 
                  value: _currentEvent,
                  onChanged: (_val) {
                    setState(() {
                      _currentEvent = _val as String;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Color.fromARGB(255, 231, 250, 60),
                    size: 40,
                  ),
                  dropdownColor: const Color.fromARGB(255, 32, 63, 60),
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
  );
  }
}