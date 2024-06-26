import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/screens/addPost/addPost_screen.dart';
import 'package:giydir_mvp2/screens/feed_screen.dart';
import 'package:giydir_mvp2/screens/message_home_screen.dart';
import 'package:giydir_mvp2/screens/profile_screen.dart';


const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const Text('Notification'),
  const AddPostScreen(),
  MessageHomeScreen(myEmail: FirebaseAuth.instance.currentUser!.email.toString()),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];