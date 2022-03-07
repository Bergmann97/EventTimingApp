import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/controllers/authentifications.dart';
import 'package:flutter/material.dart';


class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignupFormState();

}

class _SignupFormState extends State<SignupForm> {
  String email = "";
  String password = "";
  bool _isButtonDisabled = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  // ignore: must_call_super
  void initState() {
    _isButtonDisabled = true;
  }

  Future signUpNew() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future googleSignUpNew() async {
    await gooleSignIn.signIn();
  }

  // void _loginAndOpenHome() {
  //   signIn(email, password).whenComplete(() {
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
  //   });
  // }

  // void _signupAndOpenHome() {
  //   signUp(email, password).whenComplete(() {
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
  //   });
  // }
  
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
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _isButtonDisabled ? const Color.fromRGBO(70, 139, 133, 100) : const Color.fromRGBO(212, 233, 20, 100),
                        side: BorderSide(
                          color: _isButtonDisabled ? const Color.fromRGBO(232, 255, 24, 100) : const Color.fromRGBO(70, 139, 133, 100),
                        ),
                      ),
                      onPressed: _isButtonDisabled ? null : signUpNew,
                      child: Text(
                        "SignUp",
                        style: TextStyle(
                          color: _isButtonDisabled ? const Color.fromRGBO(232, 255, 24, 100) : Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromRGBO(212, 233, 20, 100),
                        side: const BorderSide(
                          color: Color.fromRGBO(70, 139, 133, 100),
                        ),
                      ),
                      onPressed: googleSignUpNew,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("lib/assets/googlelogo.png",width: MediaQuery.of(context).size.width * 0.05),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                          const Text(
                            "SignUp",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ]
                      ),
                    ),
                  ),
                ],
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