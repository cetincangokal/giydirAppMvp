import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/screens/message_screen.dart';

// ignore: must_be_immutable
class MessageHomeScreen extends StatefulWidget {
  String myEmail;

  MessageHomeScreen({super.key, required this.myEmail});

  @override
  State<MessageHomeScreen> createState() => _MessageHomeScreenState();
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class _MessageHomeScreenState extends State<MessageHomeScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mesajlar'),
        ),
        backgroundColor: Colors.grey,
        body: StreamBuilder(
          stream: getLastMeesage(widget.myEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            } else if (snapshot.data.docs.length == 0) {
              return const Center(child: Text('Mesaj yok'));
            } else {
              List<DocumentSnapshot> documents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: getDetail(documents[index].id.toString()),
                    builder: (context, snapshotFuture) {
                      if (snapshotFuture.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshotFuture.hasError) {
                        return Text('Hata: ${snapshotFuture.error}');
                      } else if (snapshotFuture.connectionState ==
                          ConnectionState.done) {
                        Map<String, dynamic> messageStreamData =
                            documents[index].data() as Map<String, dynamic>;
                        List<String>? dataList =
                            snapshotFuture.data;

                        // ignore: avoid_unnecessary_containers
                        return Container(
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(dataList![2].toString()),
                              ),
                              title: Text(dataList[1].toString()),
                              subtitle: Text(messageStreamData['mesaj'] ?? ''),
                              trailing:
                                  Text(messageStreamData['notRead'].toString()),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessageSreen(
                                          myEmail: widget.myEmail,
                                          sendEmail: dataList[0].toString()),
                                    ));
                              },
                              onLongPress: () async {
                                await _showAlertDialog(dataList[0].toString());
                              },
                            ),
                          ),
                        );
                      } else {
                        return const Text('hata');
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(String sendEmail) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sohbeti Sil'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                debugPrint(sendEmail);


                await cokluBelgeSil(sendEmail, widget.myEmail);



                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            ),
          ],
        );
      },
    );
  }
}

Future<List<String>> getDetail(String gmail) async {
  List<String> dataList = [];

  QuerySnapshot querySnapshot = await firestore
      .collection('users')
      .where('email', isEqualTo: gmail)
      .get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    dataList.add(doc['email'] as String);
    dataList.add(doc['username'] as String);
    dataList.add(doc['photoUrl'] as String);
  }
  debugPrint(dataList.toString());

  return dataList;
}

Stream getLastMeesage(String myEmail) {
  return FirebaseFirestore.instance
      .collection('Users')
      .doc(myEmail)
      .collection('UsersChat')
      .snapshots();
}



Future<void> cokluBelgeSil(String sendEmail, String myEmail) async {

  WriteBatch batch = FirebaseFirestore.instance.batch();
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users/$myEmail/UsersChat/$sendEmail/Chats').get();
  List<String> belgeIDListesi = querySnapshot.docs.map((doc) => doc.id).toList();
  debugPrint(belgeIDListesi.toString());
  for (String belgeID in belgeIDListesi) {
    batch.delete(FirebaseFirestore.instance.collection('Users/$myEmail/UsersChat/$sendEmail/Chats').doc(belgeID));
  }

  await batch.commit();
  await firestore.collection('Users').doc(myEmail).collection('UsersChat').doc(sendEmail).delete();
  // ignore: avoid_print
  print('Seçilen belgeler silindi.');
}