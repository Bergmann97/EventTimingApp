// ignore_for_file: file_names

import 'package:demo_app/widgets/events_overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User user = FirebaseAuth.instance.currentUser!;
  String _tmpText = "";
  int _selectedItem = 0;

  Future signoutNew() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _tmpText = user.email!;
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
          Container(
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
            child: const Center(
              child: Text(
                "Welcom Max Bergmann",
                style: TextStyle(
                  color: Color.fromRGBO(49, 98, 94, 50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const EventView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Timer"),
          BottomNavigationBarItem(icon: Icon(Icons.person_sharp), label: "Profil"),
        ],
        currentIndex: _selectedItem,
        onTap: (int index) {
          setState(() {
            _selectedItem = index;
          });
        },
        backgroundColor: const Color.fromRGBO(49, 98, 94, 50),
        selectedItemColor: const Color.fromARGB(255, 239, 255, 100),
        unselectedItemColor: const Color.fromARGB(156, 202, 202, 198),
      ),
    );
  }
}

