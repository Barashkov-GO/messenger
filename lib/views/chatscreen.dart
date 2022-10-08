import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_flutter/helperfunctions/sharedpref_helper.dart';
import 'package:my_first_flutter/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;

  const ChatScreen(this.chatWithUsername, this.name, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId, messageId = "";
  Stream? messagesStream;
  String? otherProfilePic;
  late String otherName, otherUserName;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUserName);
  }

  getOtherInfo() async {
    otherUserName = widget.chatWithUsername;
    otherProfilePic = (await DatabaseMethods().getUserPhoto(otherUserName))!;
    otherName = (await DatabaseMethods().getUserName(otherUserName))!;
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          //remove text in the message input field
          messageTextEditingController.text = "";

          //make message id blank to get regenerated on text message send
          messageId = "";
        }
      });
    }
  }

  Widget getMessageContainer(String message, String sendBy, bool sendByMe) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            bottomRight:
                sendByMe ? const Radius.circular(5) : const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft:
                sendByMe ? const Radius.circular(24) : const Radius.circular(5),
          ),
          color: sendByMe ? const Color(0xFF246BFD) : const Color(0xFFEAEAEA),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
            crossAxisAlignment: sendBy == myUserName
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                sendBy == myUserName ? myName : otherName,
                style: GoogleFonts.sourceSansPro(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: sendBy == myUserName
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF4582FE),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: message.length > max(myName.length, otherName.length)
                    ? 200
                    : max(myName.length, otherName.length) * 6,
                child: Text(
                  message,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.sourceSansPro(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      color: sendBy == myUserName
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF1F161E),
                    ),
                  ),
                ),
              )
            ]));
  }

  Widget chatMessageTile(String message, String myUserName, String sendBy) {
    bool sendByMe = myUserName == sendBy;

    List<Widget> childrenMyMessage = [
      getMessageContainer(message, sendBy, sendByMe),
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(myProfilePic, height: 40, width: 40),
      ),
      const SizedBox(width: 5),
    ];

    List<Widget> childrenNotMyMessage = [
      const SizedBox(width: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(otherProfilePic ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/1362px-Placeholder_view_vector.svg.png", height: 40, width: 40),
      ),
      getMessageContainer(message, sendBy, sendByMe)
    ];

    return Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sendByMe ? childrenMyMessage : childrenNotMyMessage
          ),
        ]
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
        stream: messagesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90, top: 16),
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds["message"], myUserName, ds["sendBy"]);
                  })
              : const Center(child: CircularProgressIndicator());
        });
  }

  getAndSetMessages() async {
    messagesStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    // messagesStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getOtherInfo();
    await getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
            titleSpacing: 0,
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back,
                size: 25,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            toolbarHeight: 80.0,
            backgroundColor: const Color(0xFF4582FE),
            title: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(otherProfilePic ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/1362px-Placeholder_view_vector.svg.png", height: 55, width: 55),
              ),
              const SizedBox(width: 15),
              Text(
                widget.name,
                style: GoogleFonts.sourceSansPro(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              )
            ])),
      ),
      body: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Container(
                margin:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageTextEditingController,
                          // onChanged: (value) {
                          //   addMessage(false);
                          // },
                          style: GoogleFonts.sourceSansPro(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                            ),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Сообщение",
                            hintStyle: TextStyle(color: Color(0xFF969696)),
                          ),
                        )
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF246BFD),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
