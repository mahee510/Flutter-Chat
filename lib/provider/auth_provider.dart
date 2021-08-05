import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterchat/controller/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? userId;
  String? userName;
  String? userEmail;
  String? userImage;
  String? name;

  bool get isAuth {
    return userId != null;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  loginWithGoogle() async {
    try {
      String? fcmToken;
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

      firebaseMessaging.getToken().then((token) {
        fcmToken = token;
      }).catchError((err) {
        print("fcm toekn $err");
      });
      UserCredential? response =
          await _firebaseAuth.signInWithCredential(credential);

      User? user = response.user;
      if (user != null) {
        DataBaseManger().addUserFormDB(user.uid, {
          'userId': user.uid,
          "userName": user.displayName,
          "name": user.email!.split("@")[0],
          "email": user.email,
          "imagUrl": user.photoURL,
          "fcmToken": fcmToken,
        }).then((value) {
          userId = user.uid;
          userName = user.displayName;
          userEmail = user.email;
          userImage = user.photoURL;
          name = user.email!.split("@")[0];
        });
      }

      notifyListeners();
      if (response != null) {
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'id': user!.uid,
            "userName": user.displayName,
            "email": user.email,
            "image": user.photoURL,
            "name": user.email!.split("@")[0],
            "fcmToken": fcmToken,
          },
        );
        prefs.setString('userData', userData);
      }
    } on FirebaseAuthException catch (error) {
      debugPrint("error code ${error.code}");
      String errorMessage = '';
      switch (error.code) {
        case "email-already-in-use":
          errorMessage = "The account already exists for that email.";
          break;
        case "user-not-found":
          errorMessage = "No user found for that email.";
          break;
        case "wrong-password":
          errorMessage = "Wrong password provided for that user.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      throw errorMessage;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!);
    if (extractedUserData == null || extractedUserData['id'] == null) {
      return false;
    }
    userId = extractedUserData['id'] as String;
    userName = extractedUserData['name'] as String;
    notifyListeners();
    return true;
  }

  signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    userId = null;
    userName = null;
    userEmail = null;
    userImage = null;
    name = null;
    auth.signOut();
    notifyListeners();
  }
}
