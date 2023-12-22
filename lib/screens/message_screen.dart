import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/message.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class MessageSreen extends StatefulWidget {
  String sendEmail;
  String myEmail;

  MessageSreen({super.key, required this.myEmail, required this.sendEmail});

  @override
  State<MessageSreen> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessageSreen> {
  final TextEditingController textController = TextEditingController();
  late ScrollController _scrollController;
  late Message message;
  List<QueryDocumentSnapshot> messages = [];
  QueryDocumentSnapshot? lastMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    message = Message(messages: messages, lastMessage: lastMessage);

    message
        .fetchMessagesFromFirestore(
            myEmail: widget.myEmail,
            sendEmail: widget.sendEmail,
            setter: setState)
        .then((_) => message.runStreamMeesage(
            myEmail: widget.myEmail,
            sendEmail: widget.sendEmail,
            setter: setState));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController();
    debugPrint(messages.length.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giydir'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent) {
              debugPrint('append calisti');
              message.append(
                  myEmail: widget.myEmail,
                  sendEmail: widget.sendEmail,
                  setter: setState);
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

                  Alignment messageAlignment = isMyMessage
                      ? Alignment.centerLeft
                      : Alignment.centerRight;
                  return Align(
                    alignment: messageAlignment,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      child: Card(
                        child: Align(
                            alignment: messageAlignment,
                            child: Text(messageText)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: '',
                      labelStyle: const TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Colors.deepOrange, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors.deepOrangeAccent.withOpacity(0.6),
                            width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                ElevatedButton(
                  onPressed: () {
                    String text = textController.text;
                    textController.clear();
                    //String myNumber = firebaseAuth.currentUser!.phoneNumber.toString();
                    message.sendMessage(
                        myEmail: widget.myEmail,
                        sendEmail: widget.sendEmail,
                        message: text);
                  },
                  child: const Text('Buton'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
