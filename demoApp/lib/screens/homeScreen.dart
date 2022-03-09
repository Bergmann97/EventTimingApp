// ignore_for_file: file_names

import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/widgets/events_overview.dart';
import 'package:demo_app/widgets/participants_overview.dart';
import 'package:demo_app/widgets/profil_view.dart';
import 'package:demo_app/widgets/timer_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';


class HomePage extends StatefulWidget {
  int screen;

  HomePage({Key? key, required this.screen}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _HomePageState createState() => _HomePageState(selectedItem: screen);
}

class _HomePageState extends State<HomePage> {
  User user = FirebaseAuth.instance.currentUser!;
  int selectedItem = 0;
  final db = FirebaseFirestore.instance;

  FirebaseHelper fb = FirebaseHelper();

  List<Widget> bodies = [
    const EventView(),
    const ParticipantView(),
    const TimerView(),
    const ProfilView(),
  ];

  // ignore: unused_element
  _HomePageState({Key? key, required this.selectedItem});

  Future signoutNew() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getUserProfileName() async {
    try {
      Map<String, dynamic>? doc = await fb.getUserprofil("userprofiles", user.uid);
      return doc!["firstname"] + " " + doc["secondname"];
    } catch (e) {
      log(e.toString());
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
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
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: () {
        //       // TODO: Add an Alert Dialog that asks for logout
        //       signoutNew();
        //       setState(() {
        //         _tmpText = "Logged out";
        //       });
        //     },
        //     icon: const Icon(Icons.logout)
        //   )
        // ],
        // automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
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
          bodies[selectedItem],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Participants"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Timer"),
          BottomNavigationBarItem(icon: Icon(Icons.person_sharp), label: "Profil"),
        ],
        currentIndex: selectedItem,
        onTap: (int index) {
          setState(() {
            selectedItem = index;
          });
        },
        backgroundColor: const Color.fromRGBO(49, 98, 94, 50),
        selectedItemColor: const Color.fromARGB(255, 239, 255, 100),
        unselectedItemColor: const Color.fromARGB(156, 202, 202, 198),
      ),
    );
  }
}

