import 'package:event_timing_app/controllers/authentifications.dart';
import 'package:event_timing_app/modules/dashboard/models/event.dart';
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:event_timing_app/modules/dashboard/screens/createParticipantsScreen.dart';
import 'package:event_timing_app/modules/dashboard/screens/eventCreateScreen.dart';
import 'package:event_timing_app/modules/dashboard/screens/eventViewScreen.dart';
import 'package:event_timing_app/modules/dashboard/screens/loginScreen.dart';
import 'package:event_timing_app/modules/dashboard/screens/participantScreen.dart';
import 'package:event_timing_app/modules/dashboard/screens/commingEvent.dart';
import 'package:event_timing_app/modules/dashboard/screens/startedEvent.dart';
import 'package:event_timing_app/modules/dashboard/screens/signupScreen.dart';
import 'package:event_timing_app/widgets/addParticipant.dart';
import 'package:event_timing_app/widgets/old_commingEvent.dart';
import 'package:event_timing_app/widgets/old_startedEvent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventTimingApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(uid: "CHz78WQ60tbFYJDHMvT5tGba4dx2"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  String uid = "";

  HomePage({Key? key, required this.uid}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState(uid);
}

class _HomePageState extends State<HomePage> {

  String uid = "";
  _HomePageState(this.uid);

  final db = FirebaseFirestore.instance;
  String? event;

  Sex sex = Sex.Diverse;
  String? dropdownvalue;
  String? dropdownvalue2;
  String? dropdownvalue3;

  String? firstName;
  String? secondName;
  String email = "";

  String testEventId = "FNGwQBH8Dahc1V3iTNSA";

  void showDialog2() {
    GlobalKey<FormState> formKeyP = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return const AddParticipant();
          }
        );
        
      }
    );

  }

  // TODO hier wird data erstellt
  void showdialog() {

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Event"),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              autofocus: true,    // lässt tastatur direkt erscheinen wenn Dialog öffnet
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Event",
              ),
              validator: (String? _value) {
                if (_value == null) {
                  return "Can't be Empty";
                } else {
                  return null;
                }
              },
              onChanged: (_value) {
                event = _value;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                db.collection("events").add({'event': event});
                Navigator.pop(context);
              },
              child: Text("Add"),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Event Timing App"),
          actions: <Widget>[
            IconButton(
              onPressed: () => signOutUser().whenComplete(() {
                User? user = FirebaseAuth.instance.currentUser;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }),
              icon: Icon(Icons.exit_to_app)
            )
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection("events").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data!.docs[index];   // TODO hier wird data received
                  return Container(
                    child: ListTile(
                      title: Text(ds['name']), // TODO zeige Event cool an
                      onTap:  () {
                        if (ds['started']) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => StartedEvent(eventDoc: ds,))
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CommingEvent(eventDoc: ds,))
                          );
                        }
                        // db.collection("events").doc(ds.id).update({"event": "new Value"});
                      },
                    )
                  );
                }
              );
            } else if (snapshot.hasError) {
              return CircularProgressIndicator();
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: showDialog2,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
