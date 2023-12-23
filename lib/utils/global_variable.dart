import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/screens/addPost/addPost_screen.dart';
import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/top.dart';
import 'package:giydir_mvp2/screens/feed_screen.dart';
import 'package:giydir_mvp2/screens/profile_screen.dart';
import 'package:giydir_mvp2/screens/search_screen.dart';


const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const Text('Notification'),
  const AddPostScreen(),
  const Text('Message'),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];