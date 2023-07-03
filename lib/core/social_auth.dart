import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuth {
  static Future<void> signInWithGoogle({
    required BuildContext context,
    required Function(UserCredential) onSuccess,
  }) async {
    try {
      final googleSignIn = GoogleSignIn();

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      onSuccess(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // do something
      } else if (e.code == 'invalid-credential') {
        // do something
      }
    } catch (e) {
      _showErrorMessage(context: context);
    }
  }

  static Future<void> signInWithFacebook({
    required BuildContext context,
    required Function(UserCredential) onSuccess,
  }) async {
    try {
      final loginResult = await FacebookAuth.instance.login();

      final facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken?.token ?? "");

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      onSuccess(userCredential);
    } catch (e) {
      log("FACEBOOK_ERROR $e");
      _showErrorMessage(context: context);
    }
  }

  static Future<void> signOutFromGoogle({
    required VoidCallback onNext,
  }) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    onNext();
  }

  static Future<void> signOutFromFacebook({
    required VoidCallback onNext,
  }) async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();

    onNext();
  }

  static void _showErrorMessage({
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('There is something wrong!'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // no action here
          },
        ),
      ),
    );
  }
}
