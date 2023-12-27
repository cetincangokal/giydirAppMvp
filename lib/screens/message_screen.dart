import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/message.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class MessageSreen extends StatefulWidget {
  final String sendEmail;
  final String myEmail;

  MessageSreen({super.key, required this.myEmail, required this.sendEmail});

  @override
  State<MessageSreen> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessageSreen> {
  Message message = Message();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController textController = TextEditingController();
  late ScrollController _scrollController;
  List<QueryDocumentSnapshot> messages = [];
  QueryDocumentSnapshot? lastMessage;

  @override
  void initState() {
    super.initState();
    _resetNotRead();
    _fetchMessagesFromFirestore();
    _runStreamMeesage();
  }
  Future<void> _resetNotRead() async{
    DocumentSnapshot documentSnapshot =await _firestore.doc('/Users/${widget.myEmail}/UsersChat/${widget.sendEmail}').get();
    if(documentSnapshot.exists){
      await _firestore.doc('/Users/${widget.myEmail}/UsersChat/${widget.sendEmail}').update({'notRead' : 0});
    }

  }

  _runStreamMeesage() {
    _firestore
        .collection(
            '/Users/${widget.myEmail}/UsersChat/${widget.sendEmail}/Chats')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .listen((event) {
      if (event.docs.isNotEmpty) {


      if (!messages.any((message) => message.id == event.docs.last.id)) {
        setState(() {
          messages.insert(0, event.docs.last);

        });
      }
      }
    });
  }

  Future<void> _fetchMessagesFromFirestore() async {
    final QuerySnapshot messageSnapshot = await _firestore
        .collection(
            '/Users/${widget.myEmail}/UsersChat/${widget.sendEmail}/Chats')
        .orderBy('date', descending: true)
        .limit(15)
        .get();

    setState(() {
      if (messageSnapshot.docs.isNotEmpty) {
        lastMessage = messageSnapshot.docs.last;
        messages = messageSnapshot.docs;
      }
    });
  }

  Future<void> _append() async {
    if (lastMessage == null) {
      return;
    } else {
      QuerySnapshot messageSnapshot = await _firestore
          .collection(
              '/Users/${widget.myEmail}/UsersChat/${widget.sendEmail}/Chats')
          .orderBy('date', descending: true)
          .startAfterDocument(lastMessage!)
          .limit(15)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        setState(() {
          messages.addAll(messageSnapshot.docs);
          lastMessage = messageSnapshot.docs.last;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giydir'),
          backgroundColor: Colors.grey,

        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {

                _append();
              }
            }
            return true;
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageText = messageData['mesaj'].toString();
                    String? kimdenText = messageData['kimden']?.toString();
                    bool isMyMessage = kimdenText == widget.sendEmail;
                    TextAlign textAlign =
                        isMyMessage ? TextAlign.left : TextAlign.right;
                    Alignment messageAlignment = isMyMessage
                        ? Alignment.centerLeft
                        : Alignment.centerRight;
                    Color messageColor =
                        isMyMessage ? Colors.grey : Colors.blueAccent;

                    return Align(
                      alignment: messageAlignment,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Card(
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          color: messageColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(messageText,
                                textAlign: textAlign,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8,top: 4),
                            child: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)))),
                              maxLines: null,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 2,
                        bottom: 0,
                        child: FloatingActionButton(
                          backgroundColor: Colors.black,
                          onPressed: () {
                            String text = textController.text;
                            textController.clear();
                            //String myNumber = firebaseAuth.currentUser!.phoneNumber.toString();
                            message.sendMessage(
                                sendEmail: widget.sendEmail,
                                myEmail: widget.myEmail,
                                message: text);
                          },
                          child: const Icon(Icons.send, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
}
