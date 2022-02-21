import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:provider/provider.dart';

import '../services/database.dart';
import '../widget/widget.dart';
import 'helper/constants.dart';
import 'helper/helperfunctions.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  Chat({required this.chatRoomId, required this.userName});

  static const routeName = '/Chat';

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController controller = ScrollController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        controller: controller,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return MessageTile(
                            message:
                                snapshot.data.docs[index].data()["message"],
                            sendByMe: Constants.myName ==
                                snapshot.data!.docs[index].data()["sendBy"],
                            dateTime: snapshot.data!.docs[index].data()["time"],
                          );
                        }),
                  ),
                  messageTextField(context),
                ],
              )
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      String message = messageEditingController.text;
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      Provider.of<Authenticate>(context, listen: false)
          .tryAutoLogin()
          .then((value) {
        var token = Provider.of<Authenticate>(context, listen: false).token;
        Provider.of<ApiCalls>(context, listen: false).sendMessageNotification({
          'user': widget.userName,
          'body': message,
          'Sender_Email': Constants.myName,
          'Title': widget.chatRoomId,
        }, token);
      });

      DatabaseMethods()
          .addMessage(widget.chatRoomId, chatMessageMap)
          .then((value) {
        controller.jumpTo(
          controller.position.maxScrollExtent + 80,
        );
      });

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  Future<void> getUserName() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
  }

  @override
  void initState() {
    getUserName();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
      controller.jumpTo(controller.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.userName,
          style: GoogleFonts.roboto(
              textStyle: const TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: chatMessages(),
        // Container(
        //   child: Stack(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.only(bottom: 80.0),
        //         child:
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Container messageTextField(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TextField(
                onTap: () {
                  controller.jumpTo(
                    controller.position.maxScrollExtent + 250,
                  );
                },
                controller: messageEditingController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 6,
                style: simpleTextStyle(),
                decoration: const InputDecoration(
                    hintText: "Message ...",
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    border: InputBorder.none),
              ),
            )),
            const SizedBox(
              width: 16,
            ),
            GestureDetector(
              onTap: addMessage,
              child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(230, 226, 169, 11),
                            Color.fromARGB(220, 228, 177, 11)
                          ],
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight),
                      borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    "assets/images/send.png",
                    height: 25,
                    width: 25,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final int dateTime;

  MessageTile(
      {required this.message, required this.sendByMe, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? const BorderRadius.only(
                    topLeft: const Radius.circular(23),
                    topRight: const Radius.circular(23),
                    bottomLeft: const Radius.circular(23))
                : const BorderRadius.only(
                    topLeft: const Radius.circular(23),
                    topRight: const Radius.circular(23),
                    bottomRight: const Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [
                      Color.fromARGB(218, 196, 190, 156),
                      Color.fromARGB(218, 201, 196, 180)
                    ],
            )),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            message.length > 20
                ? Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$message\n',
                            style: TextStyle(
                                color: sendByMe ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300),
                          ),
                          TextSpan(
                            text: DateFormat('hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(dateTime)),
                            style: TextStyle(
                                color: sendByMe ? Colors.white : Colors.black,
                                fontSize: 12,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$message\n',
                          style: TextStyle(
                              color: sendByMe ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(dateTime)),
                          style: TextStyle(
                              color: sendByMe ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}
