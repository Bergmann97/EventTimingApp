import 'package:demo_app/controllers/authentifications.dart';
import 'package:demo_app/main.dart';
import 'package:demo_app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();

}

class _LoginFormState extends State<LoginForm> {
  String email = "";
  String password = "";
  bool _isButtonDisabled = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    _isButtonDisabled = true;
    super.initState();
  }

  Future signInNew(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future signUpNew(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(232, 255, 24, 100),
          width: 1,
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
        color: const Color.fromRGBO(49, 98, 94, 100),
      ),
      width: MediaQuery.of(context).size.width * 0.85,
      child: Form(
        key: formkey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
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
                  labelText: "Email",
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(212, 233, 20, 100),
                  ),
                ),
                validator: (_val) {
                  if (_val!.isEmpty) {
                    return "Can't be empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  email = val;
                  if (email != "" && password != "") {
                    setState(() {
                      _isButtonDisabled = false;
                    });
                  } else {
                    setState(() {
                      _isButtonDisabled = true;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              color: const Color.fromRGBO(49, 98, 94, 100),
              child: TextFormField(
                obscureText: true,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  fillColor: Colors.white,focusColor: Colors.black,
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
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(212, 233, 20, 100),
                  ),
                ),
                validator: (_val) {
                  if (_val!.isEmpty) {
                    return "Can't be empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  password = val;
                  if (email != "" && password != "") {
                    setState(() {
                      _isButtonDisabled = false;
                    });
                  } else {
                    setState(() {
                      _isButtonDisabled = true;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: _isButtonDisabled ? const Color.fromRGBO(70, 139, 133, 100) : const Color.fromRGBO(212, 233, 20, 100),
                  side: BorderSide(
                    color: _isButtonDisabled ? const Color.fromRGBO(232, 255, 24, 100) : const Color.fromRGBO(70, 139, 133, 100),
                  ),
                ),
                onPressed: _isButtonDisabled ? null : () => signInNew(email, password),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: _isButtonDisabled ? const Color.fromRGBO(232, 255, 24, 100) : Colors.white
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.03,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
              ),
            ),
          ],
        )
      )
    );
  }
}