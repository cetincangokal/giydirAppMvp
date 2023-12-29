import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:giydir_mvp2/resources/search.dart';
import 'package:giydir_mvp2/screens/profile_screen.dart';
import 'package:giydir_mvp2/widgets/post_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isShowUsers = false;
  List<QueryDocumentSnapshot> posts = [];
  SearchGetData searchGetData = SearchGetData();
  QueryDocumentSnapshot? lastQuary;
  int pos = 1;

  @override
  void initState() {
    super.initState();
    getData(pos);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(posts.toString());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Form(
            child: TextFormField(
              controller: searchController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Search for a user...',
              ),
              onFieldSubmitted: (String _) {
                setState(() {
                  isShowUsers = true;
                });
              },
            ),
          ),
        ),
        body: isShowUsers
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'username',
                      isGreaterThanOrEqualTo: searchController.text,
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: (snapshot.data! as dynamic).docs[index]['uid'],
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]['photoUrl'],
                            ),
                            radius: 25,
                          ),
                          title: Text(
                            (snapshot.data! as dynamic).docs[index]['username'],
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      pos = 0;

                      setState(() {
                        getData(pos);
                        debugPrint(posts.length.toString());
                      });
                    } else if (_scrollController.position.pixels ==
                        _scrollController.position.minScrollExtent) {
                      pos = 1;

                      setState(() {
                        getData(pos);
                        debugPrint(posts.length.toString());
                      });
                    }
                  }
                  return true;
                },
                child: MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 3,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        (posts[index].data() as Map<String, dynamic>);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostPlayer(snap: data,isSearch: true),
                            ));
                      },
                      child: Image.network(
                        data['postUrl'],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
              ),
      );
    
  }

  void getData(int scroll) async {
    if (scroll == 1) {
      posts.clear();
    }
    List<QueryDocumentSnapshot> temp =
        await searchGetData.initPost(scroll, lastQuary);
    if (temp.isNotEmpty) {
      lastQuary = temp.last;
    }
    for (var element in temp) {
      posts.add(element);
    }

    setState(() {});
  }
}


