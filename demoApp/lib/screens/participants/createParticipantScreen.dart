// ignore_for_file: file_names

import 'package:demo_app/models/participant.dart';
import 'package:demo_app/controllers/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class CreateParticipantPage extends StatefulWidget {
  const CreateParticipantPage({Key? key}) : super(key: key);

  @override
  _CreateParticipantPageState createState() => _CreateParticipantPageState();
}

class _CreateParticipantPageState extends State<CreateParticipantPage> {

  User user = FirebaseAuth.instance.currentUser!;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  final db = FirebaseFirestore.instance;

  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController secondNameCtrl = TextEditingController();
  String genderItem = "male";
  TextEditingController ageCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();

  bool _buttonDisabled = true;

  List<String> genders = [
    Sex.male.sexToString(),
    Sex.female.sexToString(),
    Sex.diverse.sexToString(),
  ];
  
  TextStyle formText = const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 231, 250, 60)
                );

  Sex getSexFromString(String sex) {
    switch (sex) {
      case "male": return Sex.male;
      case "female": return Sex.female;
      case "diverse": return Sex.diverse;
      default: return Sex.none;
    }
  }

  createParticipant() async {
    FirebaseHelper fb = FirebaseHelper();

    try {
      Participant p = Participant(
        "TBD",
        getSexFromString(genderItem), 
        firstNameCtrl.text, 
        secondNameCtrl.text, 
        ageCtrl.text, 
        emailCtrl.text
      );

      log("Help");
      log(p.toString());

      DocumentReference? res = await fb.addDocument("participants_new", p.toJSON());
      fb.updateDocument("participants_new", res!, {'uid': res.id, 'cid': user.uid});
      Navigator.of(context).pop();
    } catch (e) {
      log(e.toString());
    }
  }

  bool isOlder16(String date) {
    DateTime today = DateTime.now();
    int birthYear = int.parse(date.split(".")[2]);
    int birthMonth = int.parse(date.split(".")[1]);
    int birthDay = int.parse(date.split(".")[0]);

    if ((today.year - birthYear) > 16) {
      return true;
    } else {  // <= 16
      if ((today.year - birthYear) == 16) {
        if (today.month < birthMonth) {
          return false;
        } else {
          if (today.month > birthMonth) {
            return true;
          } else {  // same month
            if (today.day < birthDay) {
              return false;
            } else {  // exact birthday
              return true;
            }
          }
        }
      } else {  // < 16
        return false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    formkey = GlobalKey<FormState>();
    _buttonDisabled = true;
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
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 239, 255, 100)
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView (
          child: Column(
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              const Text(
                "Create Participant",
                style: TextStyle(
                  color: Color.fromARGB(255, 231, 250, 60),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(232, 255, 24, 100),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                child: Form(
                  key: formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text("Name", style: formText, textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextFormField(
                              controller: firstNameCtrl,
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
                                errorMaxLines: 3,
                                labelText: "Firstname",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(212, 233, 20, 100),
                                ),
                              ),
                              validator: (_val) {
                                if (_val!.isEmpty) {
                                  return "Can't be empty!";
                                } else {
                                  if (_val.length > 100) {
                                    return "The firstname can be at leat 100 characters long";
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              onChanged: (_val) {
                                if (firstNameCtrl.text.isNotEmpty &&
                                    secondNameCtrl.text.isNotEmpty &&
                                    ageCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _buttonDisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _buttonDisabled = true;
                                  });
                                }
                              },
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextFormField(
                              controller: secondNameCtrl,
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
                                errorMaxLines: 3,
                                labelText: "Secondname",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(212, 233, 20, 100),
                                ),
                              ),
                              validator: (_val) {
                                if (_val!.isEmpty) {
                                  return "Can't be empty!";
                                } else {
                                  if (_val.length > 100) {
                                    return "The second can be at leat 100 characters long";
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              onChanged: (_val) {
                                if (firstNameCtrl.text.isNotEmpty &&
                                    secondNameCtrl.text.isNotEmpty &&
                                    ageCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _buttonDisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _buttonDisabled = true;
                                  });
                                }
                              },
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  height: MediaQuery.of(context).size.height * 0.12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(232, 255, 24, 100),
                                      width: 2,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.01,
                                      ),
                                      Text(
                                        "Gender",
                                        style: formText,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.22,
                                        height: MediaQuery.of(context).size.height * 0.07,
                                        child: StatefulBuilder(
                                          builder: (BuildContext context, StateSetter dropDownState) {
                                            return DropdownButton<String>(
                                              value: genderItem,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Color.fromARGB(255, 231, 250, 60),
                                              ),
                                              dropdownColor: const Color.fromARGB(255, 32, 63, 60),
                                              borderRadius: BorderRadius.circular(15.0),
                                              items: genders.map((String item) {
                                                return DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      color: const Color.fromARGB(255, 231, 250, 60),
                                                      fontWeight: item == genderItem ? FontWeight.bold : FontWeight.normal
                                                    ),
                                                  )
                                                );
                                              }).toList(),                                                
                                              onChanged: (String? newValue) { 
                                                dropDownState(() {
                                                  genderItem = newValue!;
                                                });
                                              },
                                            );
                                          }
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.1,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  // height: MediaQuery.of(context).size.height * 0.15,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Birthday",
                                          style: formText,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.01,
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          controller: ageCtrl,
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
                                            errorMaxLines: 3,
                                            labelText: "Date",
                                            labelStyle: TextStyle(
                                              color: Color.fromRGBO(212, 233, 20, 100),
                                            ),
                                          ),
                                          onTap: () async {
                                            var date = await showDatePicker(
                                              context: context, 
                                              initialDate: DateTime.now(), 
                                              firstDate: DateTime(1900), 
                                              lastDate: DateTime.now()
                                            );
                                            DateFormat formatter = DateFormat("dd.MM.yyy");
                                            if (date != null) {
                                              ageCtrl.text = formatter.format(date);
                                              if (firstNameCtrl.text.isNotEmpty &&
                                                secondNameCtrl.text.isNotEmpty &&
                                                ageCtrl.text.isNotEmpty) {
                                              setState(() {
                                                _buttonDisabled = false;
                                              });
                                            } else {
                                              setState(() {
                                                _buttonDisabled = true;
                                              });
                                            }
                                            }
                                          },
                                          validator: (_val) {
                                            if (_val!.isEmpty) {
                                              return "Can't be empty";
                                            } else {
                                              if (!RegExp(r'^\d{2}.\d{2}.\d{4}$').hasMatch(_val)) {
                                                return "The date needs the form of: dd.mm.yyyy";
                                              } else {
                                                if (!isOlder16(_val)) {
                                                  return "The user needs to be at least 16!";
                                                } else {
                                                  return null;
                                                }
                                              }
                                            }
                                          },
                                          onChanged: (_val) {
                                            if (firstNameCtrl.text.isNotEmpty &&
                                                secondNameCtrl.text.isNotEmpty &&
                                                ageCtrl.text.isNotEmpty) {
                                              setState(() {
                                                _buttonDisabled = false;
                                              });
                                            } else {
                                              setState(() {
                                                _buttonDisabled = true;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text("Email (optional)", style: formText, textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextFormField(
                              controller: emailCtrl,
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
                                errorMaxLines: 3,
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(212, 233, 20, 100),
                                ),
                              ),
                              validator: (_val) {
                                if (_val!.isNotEmpty) {
                                  if (_val.isNotEmpty && !_val.contains("@")) {
                                    return "Email must contain an @";
                                  } else {
                                    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(_val)) {
                                      return null;
                                    } else {
                                      return "Malformed email";
                                    }
                                  }
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (_val) {
                                if (firstNameCtrl.text.isNotEmpty &&
                                    secondNameCtrl.text.isNotEmpty &&
                                    ageCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _buttonDisabled = false;
                                  });
                                } else {
                                  setState(() {
                                    _buttonDisabled = true;
                                  });
                                }
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton(
                  onPressed: _buttonDisabled ? null : () {
                    if (formkey.currentState!.validate()) {
                      createParticipant();
                    }
                  }, 
                  child: const Text(
                    "Create Participant",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color.fromARGB(156, 9, 31, 29)
                    ),
                  ),
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
                      _buttonDisabled ? 
                        const Color.fromARGB(255, 145, 158, 31) : 
                        const Color.fromARGB(255, 231, 250, 60),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

