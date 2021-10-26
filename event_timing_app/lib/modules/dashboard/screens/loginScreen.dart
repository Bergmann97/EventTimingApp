// ignore_for_file: file_names

import 'package:event_timing_app/controllers/authentifications.dart';
import 'package:event_timing_app/main.dart';
import 'package:event_timing_app/modules/dashboard/screens/signupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: null
            ),
            FlutterLogo(
              size: 50.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "Login Here",
                style: TextStyle(
                  fontSize: 30.0,
                ),
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.90,
              child: Form(
                key: formkey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Email"),
                      validator: (_val) {
                          if (_val!.isEmpty) {
                            return "Can't be empty";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          email = val;
                        },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password"),
                        validator: (_val) {
                          if (_val!.isEmpty) {
                            return "Can't be empty";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          password = val;
                        },
                      ),
                    ),
                    ElevatedButton(
                        // passing an additional context parameter to show dialog boxs
                      onPressed: () => signIn(email!, password!).whenComplete(() {
                        User? user = FirebaseAuth.instance.currentUser;
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: user!.uid)));
                      }),
                      child: Text(
                        "Login",
                      ),
                    ),
                  ],
                )
              )
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () => googleSignIn().whenComplete(() {
                        User? user = FirebaseAuth.instance.currentUser;
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(uid: user!.uid)));
                      }),
              child: const Image(
                image: AssetImage('lib/assets/signin.png'),
                width: 200.0,
              )
            ),
            SizedBox(
              height: 10.0,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text(
                "Sign Up Here"
              ),
            )
          ],
        )
      )
    );
  }
}