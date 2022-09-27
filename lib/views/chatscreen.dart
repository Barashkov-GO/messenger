import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  late Stream messagesStream;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUserName);
  }

  getChatRoomIdByUsernames(String a, String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked){
    if(messageTextEditingController.text != ""){
       String message = messageTextEditingController.text;

       var lastMessageTs = DateTime.now();

       Map<String, dynamic> messageInfoMap = {
        "message" : message,
         "sendBy" : myUserName,
         "ts" : lastMessageTs,
         "imgUrl" : myProfilePic
       };

       //messageId
       if (messageId == ""){
         messageId = randomAlphaNumeric(12);
       }

       DatabaseMethods().addMessage(chatRoomId, messageId, messageInfoMap)
       .then((value) {

         Map<String, dynamic>  lastMessageInfoMap = {
           "lastMessage" : message,
           "lastMessageSendTs" : lastMessageTs,
           "lastMessageSendBy" : myUserName
         };

         DatabaseMethods().updateLastMessageSend(myUserName, lastMessageInfoMap);

         if (sendClicked){
           //remove text in the message input field
           messageTextEditingController.text = "";

           //make message id blank to get regenerated on text message send
           messageId = "";
         }
       });
    }
  }
  
  Widget chatMessageTile(String message, bool sendByMe){
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
              ),
              color: sendByMe ? Colors.blue : Colors.grey,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            )
          )
        ]
    );
  }

  Widget chatMessages(){
    return StreamBuilder(
        stream: messagesStream,
        builder: (context, snapshot){
          return snapshot.hasData
              ? ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 70,
                  top: 16
                ),
                reverse: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index){
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(ds["message"], myUserName == ds["sendBy"]);
                }
          ) : const Center(
              child: CircularProgressIndicator()
          );
        }
    );
  }

  getAndSetMessages() async {
    messagesStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
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
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageTextEditingController,
                          // onChanged: (value) {
                          //   addMessage(false);
                          // },
                          style: const TextStyle(
                            color: Colors.white
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "type a message",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6)
                            ),
                          ),
                        )
                    ),
                    GestureDetector(
                      onTap: (){
                        addMessage(true);
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
