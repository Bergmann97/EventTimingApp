// ignore_for_file: file_names

import 'package:demo_app/controllers/authentifications.dart';
import 'package:demo_app/main.dart';
import 'package:demo_app/widgets/loginform.dart';
import 'package:demo_app/widgets/signupform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
                  'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
                  'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    } else {
      print("Upsi");
    }

    return user;
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loginstate = true;
  String email = "";
  String password = "";
  bool _isButtonDisabled = true;
  bool _passwordVisible = false;
  String? _errorMsg = null;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _isButtonDisabled = true;
    _passwordVisible = false;
    _errorMsg = null;
    formkey = GlobalKey<FormState>();
    super.initState();
  }

  Future<Map> signInNew(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return {
        'message': null,
        'success': true
      };
    } catch (e) {
      return {
        'message': e.toString(),
        'success': false
      };
    }
    
  }

  Future signUpNew(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future googleSignUpNew(BuildContext context) async {
    Authentication.signInWithGoogle(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("lib/assets/runner.png", width: MediaQuery.of(context).size.height*0.15),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.05,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      // height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(232, 255, 24, 100),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
                        color: const Color.fromRGBO(49, 98, 94, 100),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 7,
                            spreadRadius: 5,
                            offset: Offset(0, 5), 
                            color: Color.fromARGB(156, 9, 31, 29)
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4222,
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => loginstate = true),
                                  child: Text("Login", style: TextStyle(
                                    fontSize: 20,
                                    color: loginstate ? Colors.white : const Color.fromRGBO(232, 255, 24, 100),
                                  ),),
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(
                                          color: Color.fromRGBO(232, 255, 24, 100)
                                        ),
                                      )
                                    ),
                                    backgroundColor: loginstate ? MaterialStateProperty.all<Color>(const Color.fromRGBO(212, 233, 20, 100)) : MaterialStateProperty.all<Color>(const Color.fromRGBO(70, 139, 133, 100)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4222,
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => loginstate = false),
                                  child: Text("Signup", style: TextStyle(
                                    fontSize: 20, 
                                    color: loginstate ? const Color.fromRGBO(232, 255, 24, 100) : Colors.white,
                                  ),),
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(
                                          color: Color.fromRGBO(232, 255, 24, 100)
                                        ),
                                      )
                                    ),
                                    backgroundColor: loginstate ? MaterialStateProperty.all<Color>(const Color.fromRGBO(70, 139, 133, 100)) : MaterialStateProperty.all<Color>(const Color.fromRGBO(212, 233, 20, 100)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(49, 98, 94, 50),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
                            ),
                            child: Form(
                              key: formkey,
                              child: Column(
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      child: TextFormField(
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(212, 233, 20, 100),
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(212, 233, 20, 100),
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          errorText: _errorMsg,
                                          errorMaxLines: 3,
                                          labelText: "Email",
                                          labelStyle: const TextStyle(
                                            color: Color.fromRGBO(212, 233, 20, 100),
                                          ),
                                        ),
                                        validator: (_val) {
                                          if (_val!.isEmpty) {
                                            return "Can't be empty";
                                          } else {
                                            if (!_val.contains("@")) {
                                              return "Email must contain an @";
                                            } else {
                                              return null;
                                            }
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
                                        keyboardType: TextInputType.emailAddress,

                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      color: const Color.fromRGBO(49, 98, 94, 100),
                                      child: TextFormField(
                                        obscureText: !_passwordVisible,
                                        keyboardType: TextInputType.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,focusColor: Colors.black,
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(212, 233, 20, 100),
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(212, 233, 20, 100),
                                              width: 2.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          labelText: "Password",
                                          hintText: "Enter your Password",
                                          hintStyle: const TextStyle(
                                            color: Color.fromRGBO(212, 233, 20, 100),
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Color.fromRGBO(212, 233, 20, 100),
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _passwordVisible = !_passwordVisible;
                                              });
                                            }, 
                                            icon: Icon(
                                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: const Color.fromARGB(156, 32, 68, 65),
                                            ),
                                          ),
                                        ),
                                        validator: (_val) {
                                          // RegExp exp = RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[*.!@$%^&(){}[]:;<>,.?/~_+-=|\]).{8,32}");
                                          if (_val!.isEmpty) {
                                            return "Can't be empty";
                                          } else {
                                            if (_val.length < 8 || _val.length > 32) {
                                              return "The password is to short or to long! (8-32 characters)";
                                            } else {
                                              if (!_val.contains(RegExp(r'[A-Z]'))) {
                                                return "The password need at least 1 uppercase letter!";
                                              } else {
                                                if (!_val.contains(RegExp(r'[a-z]'))) {
                                                  return "The password need at least 1 lowercase letter!";
                                                } else {
                                                  if (!_val.contains(RegExp(r'[0-9]'))) {
                                                    return "The password needs at least 1 digit!";
                                                  }else {
                                                    // $.*!@%#&;,<>:"_+-/
                                                    if (!_val.contains(RegExp(r'[".$*!%#&@;,<>:_+-/]'))) {
                                                      return 'The password needs at least 1 of the\nfollowing special characters: ".\$*!%#&@;,<>:_+-/';
                                                    } else {
                                                      return null;
                                                    }
                                                  }
                                                }
                                              }
                                            }
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
                                    Container(
                                      child: loginstate ? Row(
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
                                                  onPressed: _isButtonDisabled ? null : () async {
                                                    if (formkey.currentState!.validate()) {
                                                      Map result = await signInNew(email, password);
                                                      if (!result['success']) {
                                                        setState(() {
                                                          String message = result['message'];
                                                          _errorMsg = message.replaceRange(message.indexOf("["), message.indexOf("]")+2, "");
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    "Login",
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
                                                onPressed: () => googleSignUpNew(context),
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
                                      ) : Row(
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
                                              onPressed: _isButtonDisabled ? null : () => signUpNew(email, password),
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
                                              onPressed: () => googleSignUpNew(context),
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
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.02,
                                    ),
                                  ],
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
              ],
            ),
          )
    );
  }
}


                                  


// Column test = Column(
//   children: [
//     SizedBox(
//       height: MediaQuery.of(context).size.height * 0.03,
//     ),
//     SizedBox(
//       width: MediaQuery.of(context).size.width * 0.8,
//       child: TextFormField(
//         style: const TextStyle(
//           color: Colors.white,
//         ),
//         decoration: const InputDecoration(
//           fillColor: Colors.white,
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Color.fromRGBO(212, 233, 20, 100),
//               width: 2.0,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Color.fromRGBO(212, 233, 20, 100),
//               width: 2.0,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           labelText: "Email",
//           labelStyle: TextStyle(
//             color: Color.fromRGBO(212, 233, 20, 100),
//           ),
//         ),
//         validator: (_val) {
//           if (_val!.isEmpty) {
//             return "Can't be empty";
//           } else {
//             return null;
//           }
//         },
//         onChanged: (val) {
//           email = val;
//           if (email != "" && password != "") {
//             setState(() {
//               _isButtonDisabled = false;
//             });
//           } else {
//             setState(() {
//               _isButtonDisabled = true;
//             });
//           }
//         },
//       ),
//     ),
//     SizedBox(
//       height: MediaQuery.of(context).size.height * 0.01,
//     ),
//     Container(
//       width: MediaQuery.of(context).size.width * 0.8,
//       color: const Color.fromRGBO(49, 98, 94, 100),
//       child: TextFormField(
//         obscureText: true,
//         style: const TextStyle(
//           color: Colors.white,
//         ),
//         decoration: const InputDecoration(
//           fillColor: Colors.white,focusColor: Colors.black,
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Color.fromRGBO(212, 233, 20, 100),
//               width: 2.0,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Color.fromRGBO(212, 233, 20, 100),
//               width: 2.0,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           labelText: "Password",
//           labelStyle: TextStyle(
//             color: Color.fromRGBO(212, 233, 20, 100),
//           ),
//         ),
//         validator: (_val) {
//           if (_val!.isEmpty) {
//             return "Can't be empty";
//           } else {
//             return null;
//           }
//         },
//         onChanged: (val) {
//           password = val;
//           if (email != "" && password != "") {
//             setState(() {
//               _isButtonDisabled = false;
//             });
//           } else {
//             setState(() {
//               _isButtonDisabled = true;
//             });
//           }
//         },
//       ),
//     ),
//     SizedBox(
//       height: MediaQuery.of(context).size.height * 0.03,
//     ),
//   ],
// );