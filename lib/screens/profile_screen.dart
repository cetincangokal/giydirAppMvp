import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/auth_methods.dart';
import 'package:giydir_mvp2/resources/firestore_methods.dart';
import 'package:giydir_mvp2/resources/storage_methods.dart';
import 'package:giydir_mvp2/screens/login_screen.dart';
import 'package:giydir_mvp2/screens/message_screen.dart';
import 'package:giydir_mvp2/screens/post_detail_screen.dart';
import 'package:giydir_mvp2/utils/colors.dart';
import 'package:giydir_mvp2/utils/utils.dart';
import 'package:giydir_mvp2/widgets/follow_button.dart';
import 'package:giydir_mvp2/widgets/text_input.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _newPasswordController = TextEditingController();

  var userData = {};
  // int postLen = 0;
  int followers = 0;
  int following = 0;
  int postCount = 0;
  bool isFollowing = false;
  bool isLoading = false;

  late List<String> followersList;
  late List<String> followingList;

  // ignore: unused_element
  Future<void> _showFollowListDialog(
      String title, List<String> userList) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(userList[index]),
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post LENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Updated: Use length property instead of postSnap.docs.length directly
      postCount = postSnap.docs.length;

      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      // Followers listesini çek
      var followersListSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('followers')
          .get();
      followersList = await getFollowingUsernames(followersListSnap.docs);

      // Following listesini çek
      var followingListSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('following')
          .get();
      followingList = await getFollowingUsernames(followingListSnap.docs);
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context,
        e.toString(),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      // Remove the followerId from the following list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followingId)
          .collection('followers')
          .doc(followerId)
          .delete();

      // Remove the followingId from the follower list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .collection('following')
          .doc(followingId)
          .delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  Future<List<String>> getFollowingUsernames(
      List<QueryDocumentSnapshot> docs) async {
    List<String> usernames = [];

    try {
      usernames = await Future.wait(
        docs.map(
          (doc) async {
            var userSnap = await FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .get();
            return userSnap.data()!['username'];
          },
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching usernames: $e');
    }

    return usernames;
  }

  // ignore: unused_element
  void _showFullPhoto(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(imageUrl),
        );
      },
    );
  }

  void _changePassword() {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 243, 242, 242),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: 700,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    textEditingController: _newPasswordController,
                    labelText: 'New Password',
                    isPass: true,
                    textInputType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String newPassword = _newPasswordController.text.trim();

                      if (newPassword.isNotEmpty) {
                        // Şifre değiştirme metodu burada çağrılır
                        String result = await AuthMethods()
                            .changePassword(newPassword, context);

                        if (result == 'success') {
                          // Şifre değiştirildiğinde otomatik olarak çıkış yap
                          await AuthMethods().signOut();

                          // ignore: use_build_context_synchronously
                          showSnackBar(
                              context, 'Password changed successfully!');
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          showSnackBar(
                              context, 'Error changing password: $result');
                        }
                      } else {
                        showSnackBar(context, 'Please enter a new password.');
                      }
                    },
                    child: const Text('Change Password'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action is irreversible.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  await FireStoreMethods().deleteUserData(uid);
                  await StorageMethods().deleteProfilePicture(uid);
                  await StorageMethods().deletePosts(uid);
                  await AuthMethods().deleteUserData(uid);
                  // Step 5: Sign out after account deletion
                  await AuthMethods().signOut();

                  // Navigate to login screen
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, 'Error deleting account: $e');
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _addClothesInfo() {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 243, 242, 242),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        _changePassword();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        _deleteAccount(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _addClothesInfo();
                        },
                        icon: const Icon(
                          Icons.settings,
                          size: 40,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'] ?? '',
                              ),
                              radius: 70,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          child: Text(
                            userData['nameAndSurname'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                buildStatColumn(postCount, "Posts"),
                                Container(
                                  color: Colors.black54,
                                  width: 0,
                                  height: 15,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                ),
                                buildStatColumn(followers, "Followers"),
                                Container(
                                  color: Colors.black54,
                                  width: 0,
                                  height: 15,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                ),
                                buildStatColumn(following, "Following"),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? FollowButton(
                                    text: 'Sign Out',
                                    backgroundColor: mobileBackgroundColor,
                                    textColor: primaryColor,
                                    borderColor: Colors.grey,
                                    function: () async {
                                      await AuthMethods().signOut();
                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : isFollowing
                                    ? FollowButton(
                                        text: 'Unfollow',
                                        backgroundColor: Colors.white,
                                        textColor: Colors.black,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await FireStoreMethods().followUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            userData['uid'],
                                          );

                                          setState(() {
                                            isFollowing = false;
                                            followers--;
                                          });
                                        },
                                      )
                                    : FollowButton(
                                        text: 'Follow',
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await FireStoreMethods().followUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            userData['uid'],
                                          );

                                          setState(() {
                                            isFollowing = true;
                                            followers++;
                                          });
                                        },
                                      ),
                            FollowButton(
                                backgroundColor: Colors.grey,
                                borderColor: Colors.grey,
                                text: 'Mesaj',
                                textColor: Colors.white,
                                function: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MessageSreen(
                                              myEmail: FirebaseAuth
                                                  .instance.currentUser!.email
                                                  .toString(),
                                              sendEmail: userData['email']
                                                  .toString())));
                                }),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.grey,
                ),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailsScreen(
                                    currentUserId: FirebaseAuth
                                            .instance.currentUser?.uid ??
                                        '',
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              child: Image(
                                image: NetworkImage(snap['postUrl']),
                                fit: BoxFit.cover,
                              ),
                            ));
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Column buildClickableStatColumn(int num, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue, // veya istediğiniz başka bir renk
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
