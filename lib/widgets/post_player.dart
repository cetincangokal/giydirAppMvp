import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/models/user.dart' as model;
import 'package:giydir_mvp2/providers/user_providers.dart';
import 'package:giydir_mvp2/resources/firestore_methods.dart';
import 'package:giydir_mvp2/screens/comments_screen.dart';
import 'package:giydir_mvp2/screens/message_home_screen.dart';
import 'package:giydir_mvp2/screens/profile_screen.dart';
import 'package:giydir_mvp2/utils/utils.dart';
import 'package:giydir_mvp2/widgets/link_modal.dart';
import 'package:provider/provider.dart';

class PostPlayer extends StatefulWidget {
  Map<String,dynamic>  snap;
  bool? isSearch;
  PostPlayer({super.key, required this.snap,this.isSearch});

  @override
  State<PostPlayer> createState() => _PostPlayerState();
}

class _PostPlayerState extends State<PostPlayer> {
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();


  }

  // fetchCommentLen() async {
  //   try {
  //     QuerySnapshot snap = await FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.snap['postId'])
  //         .collection('comments')
  //         .get();
  //     commentLen = snap.docs.length;
  //   } catch (err) {
  //     showSnackBar(
  //       context,
  //       err.toString(),
  //     );
  //   }
  //   setState(() {});
  // }
  deletePost(String postId) async {
    try {
      String uid = widget.snap['uid'].toString(); // Kullanıcının UID'sini al
      await FireStoreMethods()
          .deletePost(postId, uid); // Gönderiyi sil ve postCount'u güncelle
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  fetchCommentLen() async {
    if (mounted) {
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .get();
        commentLen = snap.docs.length;
      } catch (err) {
        if (mounted) {
          showSnackBar(context, err.toString());
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;



    if(widget.isSearch != null && widget.isSearch == true){
      firestore.collection('posts').doc(widget.snap['postId'].toString()).snapshots().listen((event) {
        setState(() {
          widget.snap = event.data()!;
        });
      });
    }
    final size = MediaQuery.of(context).size;


    return Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onDoubleTap: () {

                    FireStoreMethods().likePost(
                      widget.snap['postId'].toString(),
                      user.uid,
                      widget.snap['likes'],

                    );


                },
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Image.network(
                    widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Expanded(
                      child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0, bottom: 10),
                              child: Text(
                                widget.snap['username'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 60, left: 4),
                              child: Text(
                                ' ${widget.snap['description']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(top: 280),
                        child: Column(
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () {},
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(
                                  side: BorderSide(
                                      strokeAlign: BorderSide.strokeAlignOutside)),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                backgroundImage: NetworkImage(
                                  widget.snap['profImage'].toString(),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: widget.snap['likes'].contains(user.uid)
                                          ? const Icon(
                                              Icons.star,
                                              color: Colors.red,
                                              size: 35,
                                            )
                                          : const Icon(
                                              Icons.star_border,
                                              size: 35,
                                            ),
                                      onPressed: () {

                                          FireStoreMethods().likePost(
                                            widget.snap['postId'].toString(),
                                            user.uid,
                                            widget.snap['likes'],
                                          );


                                      },
                                    ),
                                    DefaultTextStyle(
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(fontWeight: FontWeight.w800),
                                      child: Text(
                                        '${widget.snap['likes'].length} stars',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.comment_outlined,
                                        size: 35,
                                      ),
                                      onPressed: () => showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CommentsScreen(
                                            postId: widget.snap['postId'].toString(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.share,
                                        size: 35,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.link_sharp,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return LinkModal(
                                              postId:
                                                  widget.snap['postId'].toString(),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    if (widget.snap['uid'].toString() ==  user.uid)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Delete Post"),
                                                content: const Text(
                                                    "Are you sure you want to delete this post?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deletePost(widget.snap['postId']
                                                          .toString());
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ))
                ],
              )
            ],
          ),

    );

  }
}
