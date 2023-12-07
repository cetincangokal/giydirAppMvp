import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/screens/addPost/addPost_screen.dart';
import 'package:giydir_mvp2/screens/feed_screen.dart';
import 'package:giydir_mvp2/screens/profile_screen.dart';
import 'package:giydir_mvp2/screens/search_screen.dart';


const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text('feed'),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];