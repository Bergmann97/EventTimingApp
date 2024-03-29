
import 'package:demo_app/screens/homeScreen.dart';
import 'package:demo_app/screens/loginScreen.dart';
import 'package:flutter/material.dart';

// import 'package:demo_app/controllers/authentifications.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventTimerApp Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        canvasColor: const Color.fromARGB(156, 32, 68, 65),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: const Color.fromARGB(156, 32, 68, 65),
            backgroundColor: const Color.fromRGBO(232, 255, 24, 100),
          ),
        ),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        // '/': (context) => HomePage(screen: 0),
        '/participants': (context) => HomePage(screen: 1),
        '/timer': (context) => HomePage(screen: 2),
        '/profile': (context) => HomePage(screen: 3),
      },
    );
  }
}


class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(screen: 0,);
        } else {
          return const LoginPage();
        }
      }
    ),
  );
}