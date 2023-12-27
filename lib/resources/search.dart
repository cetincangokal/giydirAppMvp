import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SearchGetData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> initPost(int scroll,QueryDocumentSnapshot? queryDocumentSnapshot) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('posts')
        .orderBy('datePublished')
        .limit(20)
        .get();

    if (scroll == 1) {
      debugPrint('-----------1-----------');
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .orderBy('datePublished')
          .limit(20)
          .get();
       return querySnapshot.docs;
    } else if (scroll == 0 && queryDocumentSnapshot != null) {
      debugPrint('-----------0-----------');
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .orderBy('datePublished')
          .startAfterDocument(queryDocumentSnapshot)
          .limit(20)
          .get();
      if(querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs;
      }else{ return [];}
    } else {
      return querySnapshot.docs;
    }
  }
}
