import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../chat.dart';
import '../../general_chat.dart';
import '../../helper/constants.dart';
import '../../helper/helperfunctions.dart';
import '../../helper/theme.dart';
import '../../services/database.dart';

class ChatHistoryPage extends StatefulWidget {
  ChatHistoryPage({Key? key}) : super(key: key);

  static const routeName = '/ChatHistory';

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  Stream? chatRooms;

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  var senderEmail;

  getUserInfogetChats() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    senderEmail = Constants.myName;
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  Widget chatRoomsList() {
    print('Sender Email $senderEmail');
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.docs[index]
                        .data()['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId: snapshot.data.docs[index].data()["chatRoomId"],
                    receiverEmail: senderEmail !=
                            snapshot.data.docs[index]
                                .data()["users"][0]
                                .toString()
                        ? snapshot.data.docs[index]
                            .data()["users"][0]
                            .toString()
                        : snapshot.data.docs[index]
                            .data()["users"][1]
                            .toString(),
                  );
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Chats',
          style: GoogleFonts.roboto(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        child: chatRooms == null ? const SizedBox() : chatRoomsList(),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final String receiverEmail;

  ChatRoomsTile(
      {required this.userName,
      required this.chatRoomId,
      required this.receiverEmail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneralChat(
              chatRoomId: chatRoomId,
              userName: userName,
              receiverEmail: receiverEmail,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: CustomTheme.colorAccent,
                  borderRadius: BorderRadius.circular(30)),
              child: Text(userName.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(userName,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ],
        ),
      ),
    );
  }
}
