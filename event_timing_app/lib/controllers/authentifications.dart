import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

FirebaseAuth auth = FirebaseAuth.instance;
final gooleSignIn = GoogleSignIn();

Future<bool> googleSignIn() async {
  GoogleSignInAccount? googleSignInAccount = await gooleSignIn.signIn();

  if (googleSignInAccount != null) {
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
                                    idToken: googleSignInAuthentication.idToken, 
                                    accessToken: googleSignInAuthentication.accessToken);
    
    await auth.signInWithCredential(credential);

    return Future.value(true);
  } else {
    return Future.value(false);
  }
}


Future<bool> signUp(String email, String password) async {
  try {
    await auth.createUserWithEmailAndPassword(email: email, password: email);
    return Future.value(true);
  } catch (e) {
    switch (e) {
      // TODO: hier nochmal die Exceptiion anpassen
      case FirebaseAuthException:
        log("serror");
        break;
    }
    return Future.value(false);
  }
}


Future<bool> signIn(String email, String password) async {
  try {
    await auth.signInWithEmailAndPassword(email: email, password: email);
    // User? user = result.user;
    return Future.value(true);
  } catch (e) {
    switch (e) {
      // TODO: hier nochmal die Exceptiion anpassen
      case FirebaseAuthException:
        log("serror");
        break;
    }
    return Future.value(false);
  }
}


Future<bool> signOutUser() async {
  User user = auth.currentUser!;
  if (user.providerData[1].providerId == "google.com") {
    await gooleSignIn.disconnect();
  }
  await auth.signOut();
  return Future.value(true);
}