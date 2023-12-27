import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> messages = [];
  QueryDocumentSnapshot? lastMessage;


  Future<void> sendMessage(
      {required String myEmail,
      required String sendEmail,
      required String message}) async {
    WriteBatch _batch = firestore.batch();
    DocumentReference _sendCollectionReference =
        firestore.collection('Users/$sendEmail/UsersChat/$myEmail/Chats').doc();

    DocumentReference _myCollectionReference =
        firestore.collection('Users/$myEmail/UsersChat/$sendEmail/Chats').doc();

    DocumentReference _sendNotRead =
        firestore.collection('Users/$sendEmail/UsersChat').doc(myEmail);

    DocumentReference _myNotRead =
    firestore.collection('Users/$myEmail/UsersChat').doc(sendEmail);
    DocumentSnapshot sendDoc = await _sendNotRead.get();
    DocumentSnapshot myDoc = await _myNotRead.get();

    Map<String, dynamic> msj = {
      'mesaj': message,
      'date': FieldValue.serverTimestamp(),
      'kimden': myEmail
    };
    _batch.set(_sendCollectionReference, msj);
    _batch.set(_myCollectionReference, msj);

    if (sendDoc.exists) {
      _batch.update(_sendNotRead, {
        'notRead': FieldValue.increment(1),
        'mesaj': msj['mesaj'],
        'date': msj['date']
      });
    } else {
      _batch.set(
          _sendNotRead, {'notRead': 1, 'mesaj': msj['mesaj'], 'date': msj['date']});
    }
    if (myDoc.exists) {
      _batch.update(_myNotRead, {
        'mesaj': msj['mesaj'],
        'date': msj['date'],

      });
    } else {
      _batch.set(
          _myNotRead, {'mesaj': msj['mesaj'], 'date': msj['date'],'notRead': 0,});
    }

    await _batch.commit();
  }



  runStreamMeesage(
      {
      required String myEmail,
      required String sendEmail,
      required StateSetter setter}) {
    firestore
        .collection('/Users/$myEmail/UsersChat/$sendEmail/Chats')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .listen((event) {
      if (!messages.any((message) => message.id == event.docs.last.id)) {


          setter(() {
            debugPrint('calisti');
            if(event.docs.isNotEmpty){
              messages.insert(0, event.docs.last);
            }
          });
      }
    });
  }

  Future<void> fetchMessagesFromFirestore(
      {
      required String myEmail,
      required String sendEmail,
      required StateSetter setter}) async {
    final QuerySnapshot messageSnapshot = await firestore
        .collection('/Users/$myEmail/UsersChat/$sendEmail/Chats')
        .orderBy('date', descending: true)
        .limit(15)
        .get();

    setter(() {
      if(messageSnapshot.docs.isNotEmpty){
        lastMessage = messageSnapshot.docs.last;
        messages = messageSnapshot.docs;
      }
    });

  }

  Future<void> append(
      {
      required String myEmail,
      required String sendEmail,
      required StateSetter setter}) async {
    if (lastMessage == null) {
      return;
    } else {
      QuerySnapshot messageSnapshot = await firestore
          .collection('/Users/$myEmail/UsersChat/$sendEmail/Chats')
          .orderBy('date', descending: true)
          .startAfterDocument(lastMessage!) // Son belgeden sonra başla
          .limit(15)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        setter(() {
          messages.addAll(messageSnapshot.docs);
          lastMessage = messageSnapshot.docs.last;
        });
      }
    }
  }
}
