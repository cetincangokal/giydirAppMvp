import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/post_player.dart';

class PostDetailsScreen extends StatelessWidget {
  final String currentUserId; // Assuming you have the current user's UID.

  const PostDetailsScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the timeago package
    timeago.setLocaleMessages('en', timeago.EnMessages());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        title: const Text('Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Filter posts based on the current user's UID
          List<DocumentSnapshot> userPosts = snapshot.data!.docs
              .where((post) => post['uid'] == currentUserId)
              .toList();

          return PageView.builder(
            itemCount: userPosts.length,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              Map<String,dynamic> data = (userPosts[index].data() as Map<String, dynamic>);
              return PostPlayer(snap: data);
            },
          );
        },
      ),
    );
  }
}