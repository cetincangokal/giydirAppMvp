import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String nameAndSurname;
  final List followers;
  final List following;
  final String photoUrl;

  const User(
      {required this.username,
      required this.uid,
      required this.email,
      required this.photoUrl,
      required this.nameAndSurname,
      required this.followers,
      required this.following});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      nameAndSurname: snapshot["nameAndSurname"],
      photoUrl: snapshot["photoUrl"],
      followers: snapshot["followers"],
      following: snapshot["following"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "nameAndSurname": nameAndSurname,
        "followers": followers,
        "following": following,
      };
}
