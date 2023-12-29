import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/models/user.dart' as model;
import 'package:giydir_mvp2/resources/storage_methods.dart';
import 'package:giydir_mvp2/utils/utils.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String nameAndSurname,
    required Uint8List file,
    required BuildContext context,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          nameAndSurname.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          nameAndSurname: nameAndSurname,
          followers: [],
          following: [],
        );

        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter both email and password";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification send!');
    // ignore: empty_catches
    } catch (e) {}
  }

// Şifre Değiştirme
  Future<String> changePassword(String newPassword, BuildContext context) async {
    String res = "Some error occurred";
    try {
      await _auth.currentUser!.updatePassword(newPassword);

      res = "success";
    } catch (err) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Please log in again');
    }
    return res;
  }

  Future<void> deleteUserData(String uid) async {
    try {
      // Step 4: Delete the user account
      await FirebaseAuth.instance.currentUser!.delete();
      // ignore: avoid_print
      print("Step 4 Result: Success");
    } catch (e) {
      // ignore: avoid_print
      print("Error deleting user account: $e");
    }
  }

 // Şifre Sıfırlama Bağlantısı Gönderme
  Future<String> sendPasswordResetEmail(
      String email, BuildContext context) async {
    String res = "Some error occurred";
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Şifre Sıfırlama
  Future<String> resetPassword(String email, BuildContext context) async {
    String res = "Some error occurred";
    try {
      await sendPasswordResetEmail(email, context);
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Password reset email sent to $email');
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
