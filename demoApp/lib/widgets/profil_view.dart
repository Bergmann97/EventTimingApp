import 'package:demo_app/controllers/firebase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilView extends StatefulWidget {
  const ProfilView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilViewState();

}

class _ProfilViewState extends State<ProfilView> {
  User user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;

  getUserInfo(DocumentSnapshot<Object?> snapshot) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: const Text(
                        "Name: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.01,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.58,
                      child: Text(
                        snapshot["firstname"] +  
                        " " + snapshot["secondname"],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: const Text(
                        "Email: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.58,
                      child: Text(
                        user.email.toString(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: const Text(
                        "Birthdate: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.58,
                      child: Text(
                        snapshot["birthdate"] + 
                        " (" + snapshot["age"].toString() + ")",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 239, 255, 100),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width * 0.05,
            // ),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: const Icon(
            //     Icons.edit,
            //     color: Color.fromARGB(255, 32, 68, 65)
            //   ),
            //   style: ButtonStyle(
            //     shape: MaterialStateProperty.all<CircleBorder>(
            //       const CircleBorder(
            //         side: BorderSide(
            //           color: Color.fromARGB(156, 32, 68, 65),
            //           width: 2
            //         ),
            //       ),
            //     ),
            //     backgroundColor: MaterialStateProperty.all<Color>(
            //       const Color.fromARGB(255, 231, 250, 60),
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    var demo = Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width*0.9,
            height: MediaQuery.of(context).size.height*0.13,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(232, 255, 24, 100),
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              color: const Color.fromARGB(156, 54, 107, 103),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 5,
                  offset: Offset(0, 5), 
                  color: Color.fromARGB(156, 22, 73, 69)
                ),
              ],
            ),
            child: FutureBuilder(
              future: db.collection("userprofiles").doc(user.uid).get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return getUserInfo(snapshot.data!);
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Text("No data");
                }
                return const CircularProgressIndicator();
              }
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height*0.15,
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {},
            child: const Icon(
              Icons.edit,
              color: Color.fromARGB(255, 32, 68, 65)
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<CircleBorder>(
                const CircleBorder(
                  side: BorderSide(
                    color: Color.fromARGB(156, 32, 68, 65),
                    width: 2
                  ),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 231, 250, 60),
              ),
            ),
          ),
        ),
      ],
    );


    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height*0.05,
        ),
        // Container(
        //   width: MediaQuery.of(context).size.width*0.9,
        //   alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     border: Border.all(
        //       color: const Color.fromRGBO(232, 255, 24, 100),
        //       width: 1,
        //     ),
        //     borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        //     color: const Color.fromARGB(156, 54, 107, 103),
        //     boxShadow: const [
        //       BoxShadow(
        //         blurRadius: 7,
        //         spreadRadius: 5,
        //         offset: Offset(0, 5), 
        //         color: Color.fromARGB(156, 22, 73, 69)
        //       ),
        //     ],
        //   ),
        //   child: Column(
        //     children: [
        //       FutureBuilder(
        //         future: db.collection("userprofiles").doc(user.uid).get(),
        //         builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        //           if (snapshot.connectionState == ConnectionState.done) {
        //             return getUserInfo(snapshot.data!);
        //           } else if (snapshot.connectionState == ConnectionState.none) {
        //             return Text("No data");
        //           }
        //           return const CircularProgressIndicator();
        //         }
        //       ),
        //     ],
        //   ),
        // ),
        demo,
        SizedBox(
          height: MediaQuery.of(context).size.height*0.05,
        ),
        Container(
          height: MediaQuery.of(context).size.height*0.1,
          width: MediaQuery.of(context).size.width*0.9,
          alignment: Alignment.center,
          child: Text("Profile Statistics (#Participants, #events, etc)"),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(232, 255, 24, 100),
              width: 1,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: const Color.fromARGB(156, 54, 107, 103),
            boxShadow: const [
              BoxShadow(
                blurRadius: 7,
                spreadRadius: 5,
                offset: Offset(0, 5), 
                color: Color.fromARGB(156, 22, 73, 69)
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height*0.05,
        ),
        Container(
          height: MediaQuery.of(context).size.height*0.1,
          width: MediaQuery.of(context).size.width*0.9,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                // TODO
                onPressed: () {}, 
                child: Row(
                  children: [
                    const Text(
                      "Logout",
                      style: TextStyle(
                        color: Color.fromARGB(156, 32, 68, 65),
                        fontSize: 18
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                    const Icon(
                      Icons.logout,
                      color: Color.fromARGB(156, 32, 68, 65),
                    )
                  ]
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
                    const Color.fromARGB(255, 231, 250, 60),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              ElevatedButton(
                // TODO:
                onPressed: () {}, 
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  alignment: Alignment.center,
                  child: const Text(
                    "Delete Profile\n(hold)",
                    style: TextStyle(
                      color: Color.fromARGB(156, 32, 68, 65),
                      fontSize: 17
                    ),
                    textAlign: TextAlign.center,
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
                    const Color.fromARGB(255, 231, 250, 60),
                  ),
                ),
              ),
            ],
          )
        ),
      ],
    );
  }
}