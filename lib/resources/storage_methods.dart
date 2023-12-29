import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage

    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteProfilePicture(String uid) async {
    try {
      // Step 2: Delete user profile picture from Storage
      await FirebaseStorage.instance.ref().child('profilePics/$uid').delete();
      // ignore: avoid_print
      print("Step 2 Result: Success");
    } catch (e) {
      // ignore: avoid_print
      print("Error deleting profile picture: $e");
    }
  }

Future<void> deletePosts(String uid) async {
  try {
    // StorageReferans oluştur
    Reference reference = FirebaseStorage.instance.ref('posts/$uid');

    // Kullanıcının dosyalarını listele
    ListResult listResult = await reference.listAll();

    // Dosyaları sil
    await Future.forEach(listResult.items, (Reference item) async {
      await item.delete();
      // ignore: avoid_print
      print('Dosya silindi: ${item.fullPath}');
    });

    // ignore: avoid_print
    print('Kullanıcının dosyaları silindi: $uid');
  } catch (e) {
    // ignore: avoid_print
    print('Dosya silme hatası: $e');
  }
}
}
