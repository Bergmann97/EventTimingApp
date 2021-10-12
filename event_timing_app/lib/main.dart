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
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final db = FirebaseFirestore.instance;
  String? event;

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
                      title: Text(ds['event']),
                      onLongPress: () {
                        // TODO == delete
                        db.collection("events").doc(ds.id).delete();
                      },
                      onTap:  () {
                        // TODO == Update
                        db.collection("events").doc(ds.id).update({"event": "new Value"});
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
          onPressed: showdialog,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
