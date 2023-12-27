import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:giydir_mvp2/models/post.dart';
import 'package:giydir_mvp2/resources/storage_methods.dart';

import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage,
      {Map<String, dynamic>? links}) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
      await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time

      //mehmetin bok yemesi
      _firestore
          .collection('users')
          .doc(uid)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> value) {
        if (value.data()!['postCount'] == null) {
          _firestore
              .collection('users')
              .doc(uid)
              .set({'postCount': 1}, SetOptions(merge: true));
        } else {
          _firestore
              .collection('users')
              .doc(uid)
              .update({'postCount': FieldValue.increment(1)});
        }
      });

      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          likes: [],
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          links: links
        // Kategori ve link bilgilerini ekleyin
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<Map<String, dynamic>?> getPostLinks(String postId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('posts').doc(postId).get();

      if (snapshot.exists) {
        // Belge var mı kontrolü
        Map<String, dynamic>? links = snapshot.data()?['links'];
        return links;
      } else {
        print('Belge bulunamadı');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  // Future<void> addTopDetails(String link, String size, String uid) async {
  //   try {
  //     // Firestore'a ekleme işlemi
  //     await _firestore.collection('users').doc(uid).collection('top_details').add({
  //       'link': link,
  //       'size': size,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     // Hata durumunda işlemler
  //     print('Hata: $e');
  //   }
  // }

  Future<String> deleteUserData(String uid) async {
    String res = "Some error occurred";
    try {
      // Step 1: Delete user posts from Firestore
      QuerySnapshot<Map<String, dynamic>> userPostsSnapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> postSnapshot
      in userPostsSnapshot.docs) {
        await deletePost(postSnapshot.id, uid);
      }

      // Step 2: Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId, String uid) async {
    String res = "Some error occurred";
    try {
      // Gönderiyi sil
      await _firestore.collection('posts').doc(postId).delete();

      // Kullanıcının postCount'unu güncelle, negatif olmamasına dikkat et
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await _firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        int postCount = userSnapshot.data()?['postCount'] ?? 0;

        if (postCount > 0) {
          await _firestore.collection('users').doc(uid).update({
            'postCount': FieldValue.increment(-1),
          });
        }
      }

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
      await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
