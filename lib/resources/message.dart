import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> messages;
  QueryDocumentSnapshot? lastMessage;

  Message({required this.messages,required this.lastMessage});
  Future<void> sendMessage(
      {required String myEmail,
      required String sendEmail,
      required String message}) async {
    WriteBatch _batch = firestore.batch();
    DocumentReference _sendCollectionReference =
        firestore.collection('Users/$sendEmail/UsersChat/$myEmail/Chats').doc();

    DocumentReference _myCollectionReference =
        firestore.collection('Users/$myEmail/UsersChat/$sendEmail/Chats').doc();

    DocumentReference _notRead =
        firestore.collection('Users/$sendEmail/UsersChat').doc('$myEmail');
    DocumentSnapshot doc = await _notRead.get();

    Map<String, dynamic> msj = {
      'mesaj': message,
      'date': FieldValue.serverTimestamp(),
      'kimden': myEmail
    };
    _batch.set(_sendCollectionReference, msj);
    _batch.set(_myCollectionReference, msj);

    if (doc.exists) {
      _batch.update(_notRead, {
        'notRead': FieldValue.increment(1),
        'mesaj': msj['mesaj'],
        'date': msj['date']
      });
    } else {
      _batch.set(
          _notRead, {'notRead': 1, 'mesaj': msj['mesaj'], 'date': msj['date']});
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
            messages.insert(0, event.docs.last);
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
      messages.addAll(messageSnapshot.docs) ;
      lastMessage = messageSnapshot.docs.last;
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