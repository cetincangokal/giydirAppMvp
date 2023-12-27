import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MessageHome {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future aa() async {
    return firestore
        .collection('users')
        .where('email',
            arrayContainsAny: ['test5@gmail.com', 'test2@gmail.com'])
        .get()
        .then((value) {
          debugPrint(value.docs.first.toString()+'asdsadasdasd');
        });

  }


}
