import 'package:demo_app/controllers/firebase.dart';
import 'package:demo_app/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventView extends StatefulWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventViewState();

}

class _EventViewState extends State<EventView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;
  DocumentReference? docRef;
  FirebaseHelper fb = FirebaseHelper();
  double buttonfactor = 0.45;

  Widget getBodyWidget(BuildContext context, int index) {
    List widgets = [
      SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width*buttonfactor,
              height: MediaQuery.of(context).size.width*buttonfactor,
              child: TextButton(
                onPressed: () {
                  print("WTF");
                  fb.getUserDocuments("events_new", user.uid);
                }, 
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
                    Color.fromARGB(255, 255, 237, 174)
                  ),
                ),
                child: const Text(
                  "LLUT\n2018",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(156, 32, 68, 65)
                  ),
                  textAlign: TextAlign.center,
                )
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width*buttonfactor,
              height: MediaQuery.of(context).size.width*buttonfactor,
              child: TextButton(
                onPressed: () {
                  print("WTF");
                }, 
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
                    Color.fromARGB(255, 255, 237, 174)
                  ),
                ),
                child: const Text(
                  "LLUT\n2019",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(156, 32, 68, 65)
                  ),
                  textAlign: TextAlign.center,
                )
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width*buttonfactor,
              height: MediaQuery.of(context).size.width*buttonfactor,
              child: TextButton(
                onPressed: () {
                  print("WTF");
                }, 
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
                    Color.fromARGB(255, 255, 237, 174)
                  ),
                ),
                child: const Text(
                  "LLUT\n2021",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(156, 32, 68, 65)
                  ),
                  textAlign: TextAlign.center,
                )
              ),
            ),
          ],
        ),
      ),
      Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Image.asset(
            "lib/assets/Standing_Runner.png",
            width: MediaQuery.of(context).size.height*0.1
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          const Text(
            "Looks pretty empty here!\n",
            style: TextStyle(
              color: Color.fromARGB(255, 231, 250, 60),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ];

    return widgets[index];
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
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.2,
            child: ElevatedButton(
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
              onPressed: () {
                print("ADD EVENT");
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color.fromARGB(156, 32, 68, 65)),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                  const Text(
                    "Add Event",
                    style: TextStyle(
                      color: Color.fromARGB(156, 32, 68, 65),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ]
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: getBodyWidget(context, 0),
          ),
          // child: StreamBuilder<QuerySnapshot>(
          //   stream: db.collection("events_new").snapshots(),
          //   builder: (context, snapshot) {
          //     List<Widget> children;
          //     if (snapshot.hasError) {
          //       children = <Widget>[
          //         const Icon(
          //           Icons.error_outline,
          //           color: Colors.red,
          //           size: 60,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 16),
          //           child: Text('Error: ${snapshot.error}'),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 8),
          //           child: Text('Stack trace: ${snapshot.stackTrace}'),
          //         ),
          //       ];
          //     } else {
          //       switch (snapshot.connectionState) {
          //         case ConnectionState.none:
          //           children = const <Widget>[
          //             Icon(
          //               Icons.info,
          //               color: Colors.blue,
          //               size: 60,
          //             ),
          //             Padding(
          //               padding: EdgeInsets.only(top: 16),
          //               child: Text('Select a lot'),
          //             )
          //           ];
          //           break;
          //         case ConnectionState.waiting:
          //           children = const <Widget>[
          //             SizedBox(
          //               width: 60,
          //               height: 60,
          //               child: CircularProgressIndicator(),
          //             ),
          //             Padding(
          //               padding: EdgeInsets.only(top: 16),
          //               child: Text('Awaiting Events...'),
          //             )
          //           ];
          //           break;
          //         case ConnectionState.active:
          //           children = <Widget>[
          //             const Icon(
          //               Icons.check_circle_outline,
          //               color: Colors.green,
          //               size: 60,
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.only(top: 16),
          //               child: Text('\$${snapshot.data}'),
          //             )
          //           ];
          //           break;
          //         case ConnectionState.done:
          //           print(snapshot.data);
          //           break;
          //         default:
          //           print("This should not happen");
          //       }
          //     }

          //     if (!snapshot.hasData) {
                
          //       return Wrap(
          //         children: [

          //         ],
          //       );
          //     } else {
          //       return getBodyWidget(context, 1);
          //     }
          //   },
          // ),
        ),
      ],
    );
  }
}
