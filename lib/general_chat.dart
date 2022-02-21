import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/services/database.dart';
import 'package:oota/widget/widget.dart';

import 'package:provider/provider.dart';

import 'authentication/providers/api_calls.dart';
import 'authentication/providers/authenticate.dart';
import 'chat.dart';
import 'helper/constants.dart';
import 'helper/helperfunctions.dart';

class GeneralChat extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String receiverEmail;

  GeneralChat(
      {required this.chatRoomId,
      required this.userName,
      required this.receiverEmail});

  @override
  State<GeneralChat> createState() => _GeneralChatState();
}

class _GeneralChatState extends State<GeneralChat> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController controller = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

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
          'user': widget.receiverEmail,
          'body': message,
          'Sender_Email': Constants.myName,
          'Title': widget.chatRoomId,
        }, token);
      });

      DatabaseMethods()
          .addMessage(widget.chatRoomId, chatMessageMap)
          .then((value) {
        var data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
        var height = data.size.height * 0.3;
        controller.jumpTo(
          controller.position.maxScrollExtent + height,
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

      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
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
      ),
    );
  }

  Container messageTextField(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: Container(
        // height: 70,
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
                      controller.position.maxScrollExtent +
                          controller.position.pixels,
                      // curve: Curves.easeOut,
                      // duration: const Duration(milliseconds: 300),
                    );
                  },
                  controller: messageEditingController,
                  style: simpleTextStyle(),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      hintText: "Message ...",
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      border: InputBorder.none),
                ),
              ),
            ),
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
