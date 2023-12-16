import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String nameAndSurname;
  final List followers;
  final List following;
  final String photoUrl;

  const User({
    required this.username,
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.nameAndSurname,
    required this.followers,
    required this.following,
  });

  
  factory User.fromSnap(DocumentSnapshot snap) {
    final Map<String, dynamic>? snapshotData = snap.data() as Map<String, dynamic>?;

    if (snapshotData == null) {
      return const User(
        username: "",
        uid: "",
        email: "",
        nameAndSurname: "",
        photoUrl: "",
        followers: [],
        following: [],
      );
    }

    return User(
      username: snapshotData["username"] ?? "",
      uid: snapshotData["uid"] ?? "",
      email: snapshotData["email"] ?? "",
      nameAndSurname: snapshotData["nameAndSurname"] ?? "",
      photoUrl: snapshotData["photoUrl"] ?? "",
      followers: snapshotData["followers"] ?? [],
      following: snapshotData["following"] ?? [],
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
