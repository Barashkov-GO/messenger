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
  late String myName, myProfilePic, otherProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    // otherProfilePic = (await getProfilePhotoUrl(widget.name))!;
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

         DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

         if (sendClicked){
           //remove text in the message input field
           messageTextEditingController.text = "";

           //make message id blank to get regenerated on text message send
           messageId = "";
         }
       });
    }
  }

  Future<String?> getProfilePhotoUrl(String userName) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(userName ?? "");
    String? profilePicUrl = querySnapshot.docs[0]["imgUrl"];
    return profilePicUrl;
  }

  Widget getMessageContainer(String message, bool sendByMe) {
    return Container(
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            bottomRight: sendByMe ? const Radius.circular(0) : const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: sendByMe ? const Radius.circular(24) : const Radius.circular(0),
          ),
          color: sendByMe ? Colors.blue : Colors.grey,
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ]
        )
    );
  }

  Widget chatMessageTile(String message, String myUserName, String sendBy) {
    bool sendByMe = myUserName == sendBy;

    List<Widget> childrenMyMessage = [
      getMessageContainer(message, sendByMe),
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          myProfilePic ?? 'https://media.istockphoto.com/photos/dotted-grid-paper-background-texture-seamless-repeat-pattern-picture-id1320330053?b=1&k=20&m=1320330053&s=170667a&w=0&h=XisfN35UnuxAVP_sjq3ujbFDyWPurSfSTYd-Ll09Ncc=',
          height: 20,
          width: 20
        ),
      )
    ];

    List<Widget> childrenNotMyMessage = [
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
            myProfilePic ?? 'https://media.istockphoto.com/photos/dotted-grid-paper-background-texture-seamless-repeat-pattern-picture-id1320330053?b=1&k=20&m=1320330053&s=170667a&w=0&h=XisfN35UnuxAVP_sjq3ujbFDyWPurSfSTYd-Ll09Ncc=',
            height: 20,
            width: 20
        ),
      ),
      getMessageContainer(message, sendByMe)
    ];

    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column (
            children: [
              Text(
                sendBy,
                style: const TextStyle(color: Colors.black),
              ),
              Row (
                children: sendByMe ? childrenMyMessage : childrenNotMyMessage
              )
            ]
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
                  return chatMessageTile(ds["message"], myUserName, ds["sendBy"]);
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
        title: Row (
            children: [
              Image.network(
                  myProfilePic ?? 'https://media.istockphoto.com/photos/dotted-grid-paper-background-texture-seamless-repeat-pattern-picture-id1320330053?b=1&k=20&m=1320330053&s=170667a&w=0&h=XisfN35UnuxAVP_sjq3ujbFDyWPurSfSTYd-Ll09Ncc=',
                  height: 20,
                  width: 20
              ),
              const SizedBox(width: 20),
              Text(widget.name),
            ]
        )
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