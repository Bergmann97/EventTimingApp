import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final gooleSignIn = GoogleSignIn();

Future<bool> googleSignIn() async {
  GoogleSignInAccount? googleSignInAccount = await gooleSignIn.signIn();

  if (googleSignInAccount != null) {
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
                                    idToken: googleSignInAuthentication.idToken, 
                                    accessToken: googleSignInAuthentication.accessToken);
    
    UserCredential result = await auth.signInWithCredential(credential);

    User user = await auth.currentUser!;
    print(user.uid);

    return Future.value(true);
  } else {
    return Future.value(false);
  }
}


Future<bool> signUp(String email, String password) async {
  try {
    UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: email);
    // User? user = result.user;
    return Future.value(true);
  } catch (e) {
    switch (e) {
      // TODO: hier nochmal die Exceptiion anpassen
      case FirebaseAuthException:
        print("serror");
        break;
    }
    return Future.value(false);
  }
}


Future<bool> signIn(String email, String password) async {
  try {
    UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: email);
    // User? user = result.user;
    return Future.value(true);
  } catch (e) {
    switch (e) {
      // TODO: hier nochmal die Exceptiion anpassen
      case FirebaseAuthException:
        print("serror");
        break;
    }
    return Future.value(false);
  }
}


Future<bool> signOutUser() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User user = await auth.currentUser!;
  if (user.providerData[1].providerId == "google.com") {
    await gooleSignIn.disconnect();
  }
  await auth.signOut();
  return Future.value(true);
}