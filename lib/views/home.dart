
import 'package:flutter/material.dart';
import 'package:my_first_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helperfunctions/sharedpref_helper.dart';
import '../services/auth.dart';
import 'chatscreen.dart';
//import 'package:my_first_flutter/services/auth.dart';
import './signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;
  String myUserName = "";
  late String myName, myProfilePic, myEmail;
  late Stream usersStream;
  Stream chatRoomsStream = const Stream.empty();

  TextEditingController searchUsernameEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

  }

  getChatRoomIdByUsernames(String a, String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods().getUserByUserName(
        searchUsernameEditingController.text);
    setState(() {});
  }


  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true ,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"] ?? '', ds.id, myUserName);
                })
            : Center(child: CircularProgressIndicator());
      }
    );
  }

  Widget searchListUserTile({required String profileUrl, name, username, email}){
    return GestureDetector(
      onTap: (){
        
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users" : [myUserName, username],
          "lastMessage" : "",
          "lastMessageSendTs" : DateTime.now(),
          "lastMessageSendBy" : ""
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ Text(name), Text(email)])
        ],
      ),
    );
  }

  Widget searchUsersList(){
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot){
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  void getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState((){});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("messenger"),
          actions: [
            InkWell(
              onTap: () {
                AuthMethods().signOut().then((s) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()
                  ));
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = false;
                              searchUsernameEditingController.text = "";
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back)),
                        )
                      : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey ,
                              width: 1.0,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24)
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                                controller: searchUsernameEditingController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "username"
                                ),
                              )
                          ),
                          GestureDetector(
                              onTap: () {
                                if (searchUsernameEditingController.text != ""){
                                  onSearchBtnClick();
                                }
                              },
                              child: Icon(Icons.search))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSearching ? searchUsersList() : chatRoomsList()
            ],
          )
      )
    );
  }
}

class ChatRoomListTile extends StatefulWidget {

  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {

  String? profilePicUrl;
  String? name, username;

  getThisUserInfo() async {
    username = widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username ?? "");
    name = querySnapshot.docs[0]["name"];
    profilePicUrl = querySnapshot.docs[0]["imgUrl"];
    setState((){});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username ?? "", name ?? "")));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
                profilePicUrl ?? 'https://media.istockphoto.com/photos/dotted-grid-paper-background-texture-seamless-repeat-pattern-picture-id1320330053?b=1&k=20&m=1320330053&s=170667a&w=0&h=XisfN35UnuxAVP_sjq3ujbFDyWPurSfSTYd-Ll09Ncc=',
                height: 40,
                width: 40
            ),
          ),
          SizedBox(width: 3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? "", style: TextStyle(fontSize: 16)),
              SizedBox(height: 3),
              Text(widget.lastMessage)
            ],
          )
        ]
      ),
    );
  }
}


